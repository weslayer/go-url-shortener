import React, { useState } from 'react';
import axios from 'axios';
import './App.css';

const App: React.FC = () => {
  const [longUrl, setLongUrl] = useState<string>('');
  // const [userId, setUserId] = useState<string>(''); for user auth later
  const [shortUrl, setShortUrl] = useState<string>('');
  const [error, setError] = useState<string>('');

  const handleShortenUrl = async () => {
    try {
      const response = await axios.post('http://localhost:9808/create-short-url', {
        long_url: longUrl,
        user_id: "e0dba740-fc4b-4977-872c-d360239e6b1a"
      });

      setShortUrl(response.data.short_url);
      setError('');
    } catch (err: any) {
      setError('Error shortening URL. Please try again.');
      setShortUrl('');
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>URL Shortener</h1>
        <input
          type="text"
          placeholder="Enter URL"
          value={longUrl}
          onChange={(e) => setLongUrl(e.target.value)}
        />
        <button onClick={handleShortenUrl}>Shorten URL</button>
        {shortUrl && (
          <div>
            <p>Shortened URL:</p>
            <a href={shortUrl} target="_blank" rel="noopener noreferrer">{shortUrl}</a>
          </div>
        )}
        {error && <p style={{ color: 'red' }}>{error}</p>}
      </header>
    </div>
  );
}

export default App;
