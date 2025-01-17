import { useState } from 'react';
import { resizeImage } from '../../utils/fileUpload';
import { colors } from '../../theme/colors';
import { User, Upload } from 'react-feather';

interface AvatarUploadProps {
  currentAvatar?: string;
  onUpload: (file: File) => Promise<void>;
}

export const AvatarUpload = ({ currentAvatar, onUpload }: AvatarUploadProps) => {
  const [preview, setPreview] = useState<string>(currentAvatar || '');
  const [loading, setLoading] = useState(false);

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      setLoading(true);
      const resizedBlob = await resizeImage(file);
      const resizedFile = new File([resizedBlob], file.name, { type: 'image/jpeg' });
      
      const previewUrl = URL.createObjectURL(resizedBlob);
      setPreview(previewUrl);
      
      await onUpload(resizedFile);
    } catch (error) {
      console.error('Error processing image:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ marginBottom: '24px' }}>
      <div style={{
        width: '100px',
        height: '100px',
        borderRadius: '50%',
        overflow: 'hidden',
        position: 'relative',
        marginBottom: '16px',
        backgroundColor: colors.gray100
      }}>
        {preview ? (
          <img
            src={preview}
            alt="Avatar"
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover'
            }}
          />
        ) : (
          <User 
            size={40}
            color={colors.gray400}
            style={{
              position: 'absolute',
              top: '50%',
              left: '50%',
              transform: 'translate(-50%, -50%)'
            }}
          />
        )}
        
        <label style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: 'rgba(0,0,0,0.5)',
          padding: '4px',
          cursor: 'pointer',
          textAlign: 'center'
        }}>
          <Upload size={16} color={colors.white} />
          <input
            type="file"
            accept="image/*"
            onChange={handleFileChange}
            style={{ display: 'none' }}
            disabled={loading}
          />
        </label>
      </div>

      {loading && (
        <p style={{ color: colors.gray600, fontSize: '14px' }}>
          Processing image...
        </p>
      )}
    </div>
  );
};
