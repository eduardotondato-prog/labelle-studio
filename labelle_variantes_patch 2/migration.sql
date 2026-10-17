-- Esquema proposto. Converter para migração Ecto/Ash gerenciada antes de produção.
CREATE TABLE IF NOT EXISTS service_variants (
  id uuid PRIMARY KEY,
  service_id uuid NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  size varchar(1) NOT NULL CHECK (size IN ('P','M','G')),
  price numeric(12,2) NOT NULL CHECK (price >= 0),
  duration_minutes integer NOT NULL CHECK (duration_minutes > 0),
  commission_percent numeric(5,2) CHECK (commission_percent BETWEEN 0 AND 100),
  is_active boolean NOT NULL DEFAULT true,
  inserted_at timestamp without time zone NOT NULL DEFAULT now(),
  updated_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT service_variants_service_size_unique UNIQUE(service_id,size)
);
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS service_variant_id uuid REFERENCES service_variants(id);
CREATE INDEX IF NOT EXISTS appointments_service_variant_id_idx ON appointments(service_variant_id);
