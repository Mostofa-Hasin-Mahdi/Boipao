import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { base64Image } = await req.json()

    if (!base64Image) {
      return new Response(JSON.stringify({ error: 'base64Image is required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    const mistralApiKey = Deno.env.get('MISTRAL_API_KEY')
    if (!mistralApiKey) {
      return new Response(JSON.stringify({ error: 'MISTRAL_API_KEY is not set in environment' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      })
    }

    const prompt = `
      You are an AI assistant that extracts data from student ID cards.
      I will provide an image of an ID card.
      Extract the following information and return ONLY a JSON object (no markdown, no other text):
      - school_name (The full name of the school or college)
      - class_level (The class or standard, e.g., '11', '12', 'HSC 1st Year')
      - roll_number (The student's roll or ID number)
      
      Example output:
      {
        "school_name": "Dhaka College",
        "class_level": "HSC 2nd Year",
        "roll_number": "12345"
      }
    `

    const response = await fetch('https://api.mistral.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${mistralApiKey}`
      },
      body: JSON.stringify({
        model: "pixtral-12b-2409",
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: prompt },
              {
                type: "image_url",
                image_url: {
                  url: `data:image/jpeg;base64,${base64Image}`
                }
              }
            ]
          }
        ],
        temperature: 0.1,
      })
    })

    const data = await response.json()

    if (!response.ok) {
      console.error("Mistral API Error:", data)
      throw new Error(data.error?.message || 'Failed to call Mistral API')
    }

    const content = data.choices[0].message.content.trim()
    
    // Attempt to parse the JSON output from Mistral
    let parsedData
    try {
      parsedData = JSON.parse(content)
    } catch (e) {
      console.error("Failed to parse JSON from Mistral:", content)
      throw new Error("Mistral returned invalid JSON")
    }

    return new Response(JSON.stringify({ success: true, data: parsedData }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
