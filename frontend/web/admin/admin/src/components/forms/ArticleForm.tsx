import { useState } from 'react';
import { usePermissions } from '../../hooks/usePermissions';
import { Input } from '../common/Input';
import { Button } from '../common/Button';
import { colors } from '../../theme/colors';

interface ArticleFormData {
  title: string;
  content: string;
  categoryId: string;
}

interface ArticleFormProps {
  article?: {
    id: string;
    title: string;
    content: string;
    categoryId: string;
  };
  categories: { id: string; name: string; }[];
  onSubmit: (data: ArticleFormData) => Promise<void>;
  onCancel: () => void;
}

export const ArticleForm: React.FC<ArticleFormProps> = ({
  article,
  categories,
  onSubmit,
  onCancel
}) => {
  const { hasPermission } = usePermissions();
  const [formData, setFormData] = useState(article || {
    title: '',
    content: '',
    categoryId: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const canEdit = hasPermission('articles', article ? 'update' : 'create');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!canEdit) return;

    try {
      setLoading(true);
      setError(null);
      await onSubmit(formData);
    } catch (err: Error | unknown) {
      setError(err instanceof Error ? err.message : 'An unknown error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ maxWidth: '600px' }}>
      <div style={{ marginBottom: '24px' }}>
        <Input
          label="Title"
          value={formData.title}
          onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
          disabled={!canEdit || loading}
          required
        />
      </div>

      <div style={{ marginBottom: '24px' }}>
        <label style={{ display: 'block', marginBottom: '8px' }}>Content</label>
        <textarea
          value={formData.content}
          onChange={(e) => setFormData(prev => ({ ...prev, content: e.target.value }))}
          disabled={!canEdit || loading}
          style={{
            width: '100%',
            minHeight: '200px',
            padding: '8px',
            borderRadius: '4px',
            border: `1px solid ${colors.gray300}`
          }}
          required
        />
      </div>

      <div style={{ marginBottom: '24px' }}>
        <label style={{ display: 'block', marginBottom: '8px' }}>Category</label>
        <select
          value={formData.categoryId}
          onChange={(e) => setFormData(prev => ({ ...prev, categoryId: e.target.value }))}
          disabled={!canEdit || loading}
          style={{
            width: '100%',
            padding: '8px',
            borderRadius: '4px',
            border: `1px solid ${colors.gray300}`
          }}
          required
        >
          <option value="">Select a category</option>
          {categories.map(cat => (
            <option key={cat.id} value={cat.id}>{cat.name}</option>
          ))}
        </select>
      </div>

      {error && (
        <div style={{ 
          color: colors.error, 
          marginBottom: '16px',
          padding: '8px',
          backgroundColor: colors.errorLight,
          borderRadius: '4px'
        }}>
          {error}
        </div>
      )}

      <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end' }}>
        <Button
          type="button"
          variant="secondary"
          onClick={onCancel}
          disabled={loading}
        >
          Cancel
        </Button>
        {canEdit && (
          <Button
            type="submit"
            disabled={loading}
          >
            {loading ? 'Saving...' : article ? 'Update Article' : 'Create Article'}
          </Button>
        )}
      </div>
    </form>
  );
};
