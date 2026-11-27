CREATE TABLE IF NOT EXISTS public.genre (
  id_genre SERIAL PRIMARY KEY,
  nama_genre TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.penulis (
  id_penulis SERIAL PRIMARY KEY,
  nama_penulis TEXT NOT NULL,
  biografi TEXT
);

CREATE TABLE IF NOT EXISTS public.buku (
  id_buku SERIAL PRIMARY KEY,
  id_genre INTEGER NOT NULL REFERENCES public.genre(id_genre) ON DELETE RESTRICT,
  id_penulis INTEGER NOT NULL REFERENCES public.penulis(id_penulis) ON DELETE RESTRICT,
  judul_buku TEXT NOT NULL,
  penerbit TEXT NOT NULL,
  sinopsis TEXT,
  tahun_terbit INTEGER NOT NULL,
  pages INTEGER NOT NULL,
  cover TEXT NOT NULL,
  rating DOUBLE PRECISION NOT NULL DEFAULT 4.5
);

CREATE TABLE IF NOT EXISTS public.favorit (
  id_favorit SERIAL PRIMARY KEY,
  id_buku INTEGER NOT NULL REFERENCES public.buku(id_buku) ON DELETE CASCADE,
  id_user INTEGER,
  tanggal_ditambahkan TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS public."user" (
  id_user SERIAL PRIMARY KEY,
  id_favorit INTEGER REFERENCES public.favorit(id_favorit) ON DELETE SET NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

ALTER TABLE public.favorit
  ADD CONSTRAINT fk_favorit_user
  FOREIGN KEY (id_user) REFERENCES public."user"(id_user) ON DELETE CASCADE;

ALTER TABLE public.genre DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.penulis DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.buku DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorit DISABLE ROW LEVEL SECURITY;
ALTER TABLE public."user" DISABLE ROW LEVEL SECURITY;

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

INSERT INTO public.genre (nama_genre) VALUES
  ('Self-Help'),
  ('Non-Fiction'),
  ('Sci-Fi'),
  ('Fiction')
ON CONFLICT (nama_genre) DO NOTHING;

INSERT INTO public.penulis (nama_penulis, biografi) VALUES
  ('Rick Rubin', 'Rick Rubin adalah produser musik asal Amerika Serikat yang telah bekerja dengan banyak musisi lintas genre selama puluhan tahun. Ia dikenal karena pendekatan kreatifnya yang sederhana namun mendalam.'),
  ('Yuval Noah Harari', 'Yuval Noah Harari adalah sejarawan dan penulis asal Israel yang fokus meneliti sejarah besar umat manusia. Karya-karyanya banyak membahas masa lalu, masa kini, dan masa depan peradaban manusia.'),
  ('James Clear', 'James Clear adalah penulis asal Amerika Serikat yang berfokus pada kebiasaan, pengambilan keputusan, dan pengembangan diri. Ia dikenal melalui buku Atomic Habits.'),
  ('Frank Herbert', 'Frank Herbert adalah penulis fiksi ilmiah asal Amerika Serikat. Ia dikenal luas lewat seri Dune yang membahas ekologi, agama, dan politik lewat balutan cerita petualangan luar angkasa.'),
  ('Gabrielle Zevin', 'Gabrielle Zevin adalah penulis asal Amerika Serikat yang karyanya banyak mengangkat tema persahabatan, identitas, dan kreativitas dalam balutan cerita yang hangat.');

INSERT INTO public.buku (id_genre, id_penulis, judul_buku, penerbit, sinopsis, tahun_terbit, pages, cover, rating) VALUES
  (1, 1, 'The Creative Act', 'Penguin Press', 'Buku ini mengajak pembaca memandang proses berkarya sebagai jalan hidup, bukan sekadar teknik. Rick Rubin membagikan cara berpikir untuk menangkap ide, mengatasi kebuntuan, dan tetap terbuka pada hal-hal tak terduga selama berkarya.', 2023, 400, 'https://covers.openlibrary.org/b/id/13316390-M.jpg', 4.5),
  (2, 2, 'Sapiens', 'Harper', 'Buku ini menelusuri perjalanan panjang manusia, mulai dari masa pemburu-peramu hingga terbentuknya peradaban modern. Harari mengajak pembaca melihat bagaimana bahasa, kepercayaan, dan kerja sama membentuk dunia yang kita kenal sekarang.', 2015, 443, 'https://covers.openlibrary.org/b/id/8634250-M.jpg', 4.6),
  (1, 3, 'Atomic Habits', 'Avery', 'Buku ini membahas bagaimana perubahan kecil yang dilakukan secara konsisten dapat membentuk kebiasaan dan memberikan dampak besar dalam jangka panjang.', 2018, 320, 'https://covers.openlibrary.org/b/id/12539702-M.jpg', 4.8),
  (3, 4, 'Dune', 'Chilton Books', 'Kisah ini berlatar di planet gurun Arrakis, satu-satunya sumber rempah paling berharga di alam semesta. Seorang pemuda bangsawan terseret ke dalam perebutan kekuasaan, politik, dan takdir yang jauh lebih besar dari dirinya.', 1965, 600, 'https://covers.openlibrary.org/b/id/11481354-M.jpg', 4.7),
  (4, 5, 'Tomorrow, and Tomorrow, and Tomorrow', 'Knopf', 'Cerita ini mengikuti persahabatan dua perancang video game sepanjang bertahun-tahun, melewati pasang surut kreativitas, kesuksesan, dan kehilangan, sambil membangun dunia-dunia baru lewat permainan yang mereka ciptakan bersama.', 2022, 416, 'https://covers.openlibrary.org/b/id/12859975-M.jpg', 4.6);

INSERT INTO public.favorit (id_buku, tanggal_ditambahkan) VALUES
  (1, NOW()::TEXT),
  (2, NOW()::TEXT);

INSERT INTO public."user" (email, password) VALUES
  ('testing123@email.com', 'testing123|pin:123123')
ON CONFLICT (email) DO NOTHING;
