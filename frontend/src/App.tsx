import React, { useState } from 'react';
import axios, { AxiosError } from 'axios';
import './App.css';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:9808';

const App: React.FC = () => {
  const [longUrl, setLongUrl] = useState<string>('');
  const [shortUrl, setShortUrl] = useState<string>('');
  const [error, setError] = useState<string>('');

  const handleShortenUrl = async () => {
    try {
      const response = await axios.post(`${API_URL}/create-short-url`, {
        long_url: longUrl
      });

      setShortUrl(response.data.short_url);
      setError('');
    } catch (error) {
      const errorMessage = error instanceof AxiosError 
        ? error.response?.data?.error || 'Error shortening URL'
        : 'Error shortening URL';
      setError(errorMessage);
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
