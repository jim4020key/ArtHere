import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('PROJECT_URL') as string;
const supabaseKey = Deno.env.get('PROJECT_API_KEY') as string;
const apiKey = Deno.env.get('MUSEUM_API_KEY') as string;

const supabase = createClient(supabaseUrl, supabaseKey);

interface Museum {
  fcltyNm: string;
  rdnmadr: string;
  homepageUrl: string;
  latitude: string;
  longitude: string;
  referenceDate?: string;
}

interface ApiResponse {
  response: {
    body: {
      totalCount: number;
      items: Museum[];
    };
  };
}

async function fetchMuseumPage(pageNo: number, numOfRows: number): Promise<Museum[]> {
  const apiUrl = `http://api.data.go.kr/openapi/tn_pubr_public_museum_artgr_info_api?serviceKey=${apiKey}&pageNo=${pageNo}&numOfRows=${numOfRows}&type=json`;
  console.log(`Fetching data from page ${pageNo}: ${apiUrl}`);

  const response = await fetch(apiUrl);
  if (!response.ok) {
    throw new Error(`API request failed for page ${pageNo} with status: ${response.status}`);
  }

  const data = await response.json() as ApiResponse;
  if (!data || !data.response || !data.response.body) {
    throw new Error(`Invalid API response structure for page ${pageNo}`);
  }

  return (data.response.body?.items || []).map(item => ({
    fcltyNm: item.fcltyNm,
    rdnmadr: item.rdnmadr,
    homepageUrl: item.homepageUrl,
    latitude: item.latitude,
    longitude: item.longitude,
    referenceDate: item.referenceDate
  }));
}

function deduplicateMuseums(museums: Museum[]): Museum[] {
  const uniqueMuseumsMap = new Map<string, Museum>();

  museums.forEach(museum => {
    if (!museum.fcltyNm) return;

    if (!uniqueMuseumsMap.has(museum.fcltyNm)) {
      uniqueMuseumsMap.set(museum.fcltyNm, museum);
    } else {
      const existingMuseum = uniqueMuseumsMap.get(museum.fcltyNm)!;
      const existingDate = existingMuseum.referenceDate || '';
      const newDate = museum.referenceDate || '';

      if (newDate > existingDate) {
        uniqueMuseumsMap.set(museum.fcltyNm, museum);
      }
    }
  });

  return Array.from(uniqueMuseumsMap.values());
}

async function upsertMuseumBatches(museums: Museum[]): Promise<number> {
  const batchSize = 50;
  let updatedCount = 0;

  for (let i = 0; i < museums.length; i += batchSize) {
    const batch = museums.slice(i, i + batchSize);
    const museumBatch = batch.map(museum => ({
      name: museum.fcltyNm,
      address: museum.rdnmadr,
      homepage_url: museum.homepageUrl,
      latitude: parseFloat(museum.latitude),
      longitude: parseFloat(museum.longitude),
      last_updated: new Date().toISOString()
    }));

    if (museumBatch.length > 0) {
      console.log(`Upserting batch ${Math.floor(i/batchSize) + 1}/${Math.ceil(museums.length/batchSize)} (${museumBatch.length} items)`);

      const { error, count } = await supabase.from('museums')
        .upsert(museumBatch, { onConflict: 'name', count: 'exact' });

      if (error) {
        console.error(`Error upserting batch:`, error);
      } else {
        updatedCount += count || 0;
      }
    }
  }

  return updatedCount;
}

Deno.serve(async (req) => {
  try {
    const numOfRows = 100;
    let allMuseums: Museum[] = [];

    const firstPageMuseums = await fetchMuseumPage(1, numOfRows);
    allMuseums = firstPageMuseums;

    const firstResponse = await fetch(`http://api.data.go.kr/openapi/tn_pubr_public_museum_artgr_info_api?serviceKey=${apiKey}&pageNo=1&numOfRows=${numOfRows}&type=json`);
    const firstData = await firstResponse.json() as ApiResponse;
    const totalCount = firstData.response.body.totalCount;
    const totalPages = Math.ceil(totalCount / numOfRows);

    console.log(`Total count: ${totalCount}, Total pages: ${totalPages}`);

    const pagePromises = [];
    for (let pageNo = 2; pageNo <= totalPages; pageNo++) {
      pagePromises.push(fetchMuseumPage(pageNo, numOfRows));
    }

    try {
      const results = await Promise.allSettled(pagePromises);

      results.forEach((result, index) => {
        if (result.status === 'fulfilled') {
          allMuseums.push(...result.value);
        } else {
          console.error(`Failed to fetch page ${index + 2}: ${result.reason}`);
        }
      });
    } catch (error) {
      console.error("Error fetching museum pages:", error);
    }

    console.log(`Found total ${allMuseums.length} museums before deduplication`);

    const uniqueMuseums = deduplicateMuseums(allMuseums);
    console.log(`Found ${uniqueMuseums.length} unique museums after deduplication`);

    const updatedCount = await upsertMuseumBatches(uniqueMuseums);

    return new Response(JSON.stringify({
      success: true,
      total: allMuseums.length,
      unique: uniqueMuseums.length,
      updated: updatedCount
    }), {
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error("Error in update-museums function:", error);
    return new Response(JSON.stringify({
      error: error.message,
      stack: error.stack
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});
