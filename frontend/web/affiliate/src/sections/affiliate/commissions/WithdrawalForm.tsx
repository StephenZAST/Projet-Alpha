import { Card, Stack, TextField, Button, Alert, MenuItem } from '@mui/material';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';

const PAYMENT_METHODS = [
  { value: 'MOBILE_MONEY', label: 'Mobile Money' },
  { value: 'ORANGE_MONEY', label: 'Orange Money' },
  { value: 'BANK_TRANSFER', label: 'Virement Bancaire' }
] as const;

const withdrawalSchema = z.object({
  amount: z.number().min(100, 'Minimum withdrawal is 100'),
  paymentMethod: z.enum(['BANK_TRANSFER', 'PAYPAL', 'MOBILE_MONEY']),
  accountDetails: z.object({
    accountName: z.string().optional(),
    accountNumber: z.string().optional(),
    bankName: z.string().optional(),
    paypalEmail: z.string().email().optional(),
    phoneNumber: z.string().optional()
  })
});

export function WithdrawalForm() {
  const queryClient = useQueryClient();
  const { mutate, isLoading } = useMutation({
    mutationFn: AffiliateApi.requestWithdrawal,
    onSuccess: () => {
      queryClient.invalidateQueries(['commissions']);
      // Show success toast
    }
  });

  const { register, handleSubmit, formState: { errors } } = useForm<WithdrawalRequest>({
    resolver: zodResolver(withdrawalSchema)
  });

  const [method, setMethod] = useState('');

  const handleMethodChange = (event) => {
    setMethod(event.target.value);
  };

  return (
    <Card sx={{ p: 3 }}>
      <Stack spacing={3}>
        <TextField
          select
          fullWidth
          label="Méthode de Paiement"
          value={method}
          onChange={handleMethodChange}
        >
          {PAYMENT_METHODS.map((option) => (
            <MenuItem key={option.value} value={option.value}>
              {option.label}
            </MenuItem>
          ))}
        </TextField>

        {/* Champs conditionnels basés sur la méthode de paiement */}
        {method === 'BANK_TRANSFER' && (
          <>
            <TextField fullWidth label="Nom de la Banque" {...register('accountDetails.bankName')} />
            <TextField fullWidth label="Numéro de Compte" {...register('accountDetails.accountNumber')} />
          </>
        )}

        {(method === 'MOBILE_MONEY' || method === 'ORANGE_MONEY') && (
          <TextField fullWidth label="Numéro de Téléphone" {...register('accountDetails.phoneNumber')} />
        )}

        {/* ...reste du formulaire... */}
      </Stack>
    </Card>
  );
}
