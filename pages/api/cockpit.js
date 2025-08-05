// Dedicated Cockpit proxy route
// This handles the Cockpit web interface properly

export default async function handler(req, res) {
  const { method } = req;
  const cockpitUrl = 'http://5.78.70.68:9090';

  // Handle preflight requests
  if (method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, Cookie');
    res.setHeader('Access-Control-Allow-Credentials', 'true');
    return res.status(200).end();
  }

  try {
    console.log('Cockpit proxy request:', method, req.url);
    
    // Build the target URL
    const targetPath = req.url.replace('/api/cockpit', '') || '/';
    const targetUrl = `${cockpitUrl}${targetPath}`;
    
    console.log('Proxying to:', targetUrl);

    // Forward the request to Cockpit
    const response = await fetch(targetUrl, {
      method,
      headers: {
        'Host': '5.78.70.68:9090',
        'User-Agent': req.headers['user-agent'] || 'Mozilla/5.0',
        'Accept': req.headers['accept'] || 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': req.headers['accept-language'] || 'en-US,en;q=0.5',
        'Accept-Encoding': 'identity', // Disable compression for simplicity
        'Connection': 'keep-alive',
        ...(req.headers['cookie'] && { 'Cookie': req.headers['cookie'] }),
        ...(req.headers['authorization'] && { 'Authorization': req.headers['authorization'] }),
        ...(method !== 'GET' && req.headers['content-type'] && { 'Content-Type': req.headers['content-type'] }),
      },
      body: method !== 'GET' && req.body ? JSON.stringify(req.body) : undefined,
    });

    // Get response data
    const data = await response.arrayBuffer();
    const buffer = Buffer.from(data);
    
    // Set response headers
    const contentType = response.headers.get('content-type') || 'text/html';
    res.setHeader('Content-Type', contentType);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Credentials', 'true');
    
    // Forward cookies and other important headers
    const setCookie = response.headers.get('set-cookie');
    if (setCookie) {
      res.setHeader('Set-Cookie', setCookie);
    }
    
    const location = response.headers.get('location');
    if (location) {
      // Rewrite location header to point to our proxy
      const rewrittenLocation = location.replace('http://5.78.70.68:9090', '/api/cockpit');
      res.setHeader('Location', rewrittenLocation);
    }

    res.status(response.status).send(buffer);
    
  } catch (error) {
    console.error('Cockpit proxy error:', error);
    res.status(500).json({
      error: 'Failed to connect to Cockpit',
      message: error.message,
      cockpitUrl: cockpitUrl
    });
  }
}
