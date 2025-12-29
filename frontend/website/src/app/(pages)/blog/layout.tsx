/**
 * 📝 Blog Layout - Layout pour les pages blog
 */

import React from 'react';

export default function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div>
      {children}
    </div>
  );
}
