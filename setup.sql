-- Run this once in Supabase: Dashboard > SQL Editor > New query > paste > Run

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  razorpay_payment_id text unique,
  amount integer,
  status text not null default 'paid',
  created_at timestamptz not null default now()
);

-- Row Level Security: users can only READ their own purchase (matched by email).
-- Nobody can insert/update/delete from the browser. Only your server (webhook) can.
alter table public.purchases enable row level security;

drop policy if exists "read own purchase" on public.purchases;
create policy "read own purchase"
  on public.purchases for select
  to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email'));

-- TESTING ONLY: mark yourself as paid to test the dashboard.
-- Replace the email with the one you signed up with, then run this line.
-- insert into public.purchases (email, status) values ('you@example.com', 'paid');
