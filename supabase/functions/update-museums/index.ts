import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';
import { parse } from "https://denopkg.com/ThauEx/deno-fast-xml-parser/mod.ts";

const OPEN_API_BASE_URL = 'http://apis.data.go.kr/B553457/nopenapi/rest/publicperformancedisplays';
const REALM_CODE = 'D000';
const PAGE_SIZE = 100;

interface Exhibition {
  seq: string;
  title: string;
  place: string;
  startDate: string;
  endDate: string;
  area: string;
  gpsX?: string;
  gpsY?: string;
}

interface Museum {
  name: string;
  longitude: number | null;
  latitude: number | null;
  exhibitions: string[];
}

function getCurrentDateString(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}${month}${day}`;
}

function isOngoingExhibition(startDate: string, endDate: string): boolean {
  const today = getCurrentDateString();
  return today >= startDate && today <= endDate;
}

serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('PROJECT_URL') || '';
    const supabaseKey = Deno.env.get('PROJECT_API_KEY') || '';

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('PROJECT_URL or PROJECT_API_KEY environment variables are not set.');
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    const serviceKey = Deno.env.get('MUSEUM_API_KEY') || '';
    if (!serviceKey) {
      throw new Error('MUSEUM_API_KEY environment variable is not set.');
    }

    const initialUrl = `${OPEN_API_BASE_URL}/realm?realmCode=${REALM_CODE}&PageNo=1&numOfrows=1&serviceKey=${serviceKey}`;
    console.log('Initiating API call...');

    const initialResponse = await fetch(initialUrl);
    if (!initialResponse.ok) {
      throw new Error(`Initial API call failed: ${initialResponse.status} ${initialResponse.statusText}`);
    }

    const initialXml = await initialResponse.text();
    const initialDoc = parse(initialXml, {
      ignoreAttributes: false,
      attributeNamePrefix: "@_",
      parseNodeValue: true,
      trimValues: true
    });

    if (!initialDoc || !initialDoc.response) {
      throw new Error('Initial XML parsing failed or unexpected response structure');
    }

    const header = initialDoc.response.header || {};
    const resultMsg = header.resultMsg || 'Unknown error';

    if (resultMsg && resultMsg.includes("정상")) {
      console.log("API responded successfully");
    } else {
      const resultCode = header.reseultCode || header.resultCode;
      throw new Error(`API error: ${resultCode || 'undefined'} - ${resultMsg}`);
    }

    const body = initialDoc.response.body || {};
    const totalCount = parseInt(body.totalCount || '0');

    if (totalCount === 0) {
      return new Response(
        JSON.stringify({ success: true, message: "No search results found." }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    const totalPages = Math.ceil(totalCount / PAGE_SIZE);
    console.log(`Processing ${totalCount} exhibition items across ${totalPages} pages.`);

    const museums: Record<string, Museum> = {};

    for (let page = 1; page <= totalPages; page++) {
      const dataUrl = `${OPEN_API_BASE_URL}/realm?realmCode=${REALM_CODE}&PageNo=${page}&numOfrows=${PAGE_SIZE}&serviceKey=${serviceKey}`;
      console.log(`Processing page ${page}/${totalPages}...`);

      const response = await fetch(dataUrl);
      if (!response.ok) {
        console.error(`Failed to fetch page ${page}: ${response.status} ${response.statusText}`);
        continue;
      }

      const xmlText = await response.text();
      const xmlDoc = parse(xmlText, {
        ignoreAttributes: false,
        attributeNamePrefix: "@_",
        parseNodeValue: true,
        trimValues: true
      });

      if (!xmlDoc || !xmlDoc.response) {
        console.error(`Failed to parse XML for page ${page}`);
        continue;
      }

      const pageHeader = xmlDoc.response.header || {};
      const pageResultMsg = pageHeader.resultMsg || '';

      if (!pageResultMsg.includes("정상")) {
        const pageResultCode = pageHeader.reseultCode || pageHeader.resultCode;
        console.error(`API error on page ${page}: ${pageResultCode} - ${pageResultMsg}`);
        continue;
      }

      const pageBody = xmlDoc.response.body || {};
      const items = pageBody.items?.item;

      if (!items) {
        console.log(`No items found on page ${page}`);
        continue;
      }

      const itemArray = Array.isArray(items) ? items : [items];
      let processedItems = 0;

      itemArray.forEach((item) => {
        try {
          const startDate = item.startDate || "";
          const endDate = item.endDate || "";

          if (isOngoingExhibition(startDate, endDate)) {
            const place = item.place || "";
            if (!place) return;

            const exhibition: Exhibition = {
              seq: item.seq || "",
              title: item.title || "",
              place,
              startDate,
              endDate,
              area: item.area || "",
              gpsX: item.gpsX || null,
              gpsY: item.gpsY || null
            };

            if (!museums[exhibition.place]) {
              museums[exhibition.place] = {
                name: exhibition.place,
                longitude: exhibition.gpsX ? parseFloat(exhibition.gpsX) : null,
                latitude: exhibition.gpsY ? parseFloat(exhibition.gpsY) : null,
                exhibitions: []
              };
            }

            if (!museums[exhibition.place].exhibitions.includes(exhibition.seq)) {
              museums[exhibition.place].exhibitions.push(exhibition.seq);
            }

            processedItems++;
          }
        } catch (error) {
          console.error(`Error processing exhibition data: ${error.message}`);
        }
      });

      console.log(`Page ${page}: Processed ${processedItems} ongoing exhibitions`);

      if (page < totalPages) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }

    const museumArray = Object.values(museums);
    console.log(`Collected information for ${museumArray.length} museums.`);

    if (museumArray.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: "No museums with ongoing exhibitions found." }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    let updatedCount = 0;
    let insertedCount = 0;
    let errorCount = 0;

    for (const museum of museumArray) {
      try {
        const { data: existingMuseum, error: selectError } = await supabase
          .from('museums')
          .select('id, name, exhibitions')
          .eq('name', museum.name)
          .maybeSingle();

        if (selectError) {
          console.error(`Failed to query museum (${museum.name}):`, selectError);
          errorCount++;
          continue;
        }

        if (existingMuseum) {
          const mergedExhibitions = [...new Set([
            ...(existingMuseum.exhibitions || []),
            ...museum.exhibitions
          ])];

          const { error: updateError } = await supabase
            .from('museums')
            .update({
              longitude: museum.longitude,
              latitude: museum.latitude,
              exhibitions: mergedExhibitions,
              last_updated: new Date().toISOString()
            })
            .eq('id', existingMuseum.id);

          if (updateError) {
            console.error(`Failed to update museum (${museum.name}):`, updateError);
            errorCount++;
          } else {
            console.log(`Updated museum information: ${museum.name}`);
            updatedCount++;
          }
        } else {
          const { error: insertError } = await supabase
            .from('museums')
            .insert({
              name: museum.name,
              longitude: museum.longitude,
              latitude: museum.latitude,
              exhibitions: museum.exhibitions,
              last_updated: new Date().toISOString()
            });

          if (insertError) {
            console.error(`Failed to add museum (${museum.name}):`, insertError);
            errorCount++;
          } else {
            console.log(`Added new museum: ${museum.name}`);
            insertedCount++;
          }
        }
      } catch (error) {
        console.error(`Error processing museum (${museum.name}):`, error.message);
        errorCount++;
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Processed information for ${museumArray.length} museums.`,
        stats: {
          total: museumArray.length,
          updated: updatedCount,
          inserted: insertedCount,
          errors: errorCount
        },
        timestamp: new Date().toISOString()
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200
      }
    );

  } catch (error) {
    console.error("Error occurred during processing:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        stack: error.stack
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500
      }
    );
  }
});
