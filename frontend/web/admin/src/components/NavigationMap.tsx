import React, { useState, useEffect } from 'react';
import { GoogleMap, LoadScript } from '@react-google-maps/api';
import axios from 'axios';
import styles from './style/NavigationMap.module.css';

interface Marker {
  name: string;
  lat: number;
  lng: number;
}

const NavigationMap: React.FC = () => {
  const [mapData, setMapData] = useState<Marker[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchMapData = async () => {
      setLoading(true);
      try {
        const response = await axios.get('/api/navigation-map');
        setMapData(response.data);
      } catch (error) {
        if (error instanceof Error) {
          setError(error);
        } else {
          setError(new Error('Unknown error'));
        }
      } finally {
        setLoading(false);
      }
    };
    fetchMapData();
  }, []);

  const mapStyles = {
    height: '400px',
    width: '100%',
  };

  const defaultCenter = {
    lat: 40.712776,
    lng: -74.005974,
  };

  return (
    <div className={styles.navigationMapContainer}>
      <h2>Navigation Map</h2>
      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>Error: {error.message}</p>
      ) : (
        <LoadScript googleMapsApiKey="YOUR_API_KEY">
          <GoogleMap
            mapContainerStyle={mapStyles}
            center={defaultCenter}
            zoom={9}
          >
            {mapData.map((marker, index) => (
              <div key={index}>{marker.name}</div>
            ))}
          </GoogleMap>
        </LoadScript>
      )}
    </div>
  );
};

export default NavigationMap;
