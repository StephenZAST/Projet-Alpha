import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Address {
  id?: string;
  userId: string;
  street: string;
  city: string;
  state?: string;
  zipCode?: string;
  country: string;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store address data
const addressesTable = 'addresses';

// Function to get address data
export async function getAddress(id: string): Promise<Address | null> {
  const { data, error } = await supabase.from(addressesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch address', 'INTERNAL_SERVER_ERROR');
  }

  return data as Address;
}

// Function to create address
export async function createAddress(addressData: Address): Promise<Address> {
  const { data, error } = await supabase.from(addressesTable).insert([addressData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create address', 'INTERNAL_SERVER_ERROR');
  }

  return data as Address;
}

// Function to update address
export async function updateAddress(id: string, addressData: Partial<Address>): Promise<Address> {
  const currentAddress = await getAddress(id);

  if (!currentAddress) {
    throw new AppError(404, 'Address not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(addressesTable).update(addressData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update address', 'INTERNAL_SERVER_ERROR');
  }

  return data as Address;
}

// Function to delete address
export async function deleteAddress(id: string): Promise<void> {
  const address = await getAddress(id);

  if (!address) {
    throw new AppError(404, 'Address not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(addressesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete address', 'INTERNAL_SERVER_ERROR');
  }
}
