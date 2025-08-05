// API route to proxy requests to your Hetzner server
// This helps bypass CORS and company restrictions

export default async function handler(req, res) {
  const { method, body } = req;
  const { target, serverUrl, endpoint } = req.query;

  // Support both 'target' and 'serverUrl' parameters
  const targetUrl = target || `${serverUrl}${endpoint || ''}`;

  if (!targetUrl) {
    return res.status(400).json({ error: 'Target URL is required' });
  }

  try {
    console.log('Proxying request to:', targetUrl);
    
    const response = await fetch(targetUrl, {
      method,
      headers: {
        'Content-Type': req.headers['content-type'] || 'text/html',
        'User-Agent': 'Hetzner-Dashboard-Proxy',
        'Accept': req.headers['accept'] || 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
      body: method !== 'GET' && body ? JSON.stringify(body) : undefined,
    });

    const contentType = response.headers.get('content-type') || 'text/html';
    const data = await response.text();
    
    // Set appropriate headers for web content
    res.setHeader('Content-Type', contentType);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    res.status(response.status).send(data);
  } catch (error) {
    console.error('Proxy error:', error);
    res.status(500).json({
      error: 'Failed to connect to server',
      message: error.message,
      targetUrl: targetUrl
    });
  }
}
