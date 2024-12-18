--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 16.4

-- Started on 2024-12-18 13:02:07

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3475 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 254 (class 1255 OID 24836)
-- Name: deriurun_bilgilerini_goster(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deriurun_bilgilerini_goster() RETURNS TABLE(urunid integer, urunad character varying, kategoriad character varying, tabaklamaad character varying, kaynakad character varying, yuzeyad character varying, stokmiktari integer, satisfiyati integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.urunid,
        d.urunad,
        k."kategoriAd",         -- Kategori Adı
        t."tabaklamaAd",        -- Tabaklama Adı
        y."kaynakAd",           -- Kaynak Adı
        y."yuzeyAd",            -- Yüzey İşleme Adı
        d.stokmiktari,
        d.satisfiyati
    FROM
        public.deriurun d
    JOIN
        public.kategori k ON d.kategoriid = k.kategoriid
    JOIN
        public.tabaklamatur t ON d.tabaklamaid = t.tabaklamaTurid
    JOIN
        public.kaynak y ON d.kaynakid = y.kaynakTurid
    JOIN
        public.yuzeyislemesi y2 ON d.yuzeyid = y2.islemeTurid;
END;
$$;


ALTER FUNCTION public.deriurun_bilgilerini_goster() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 24826)
-- Name: hedef_kota_yuzdesi(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.hedef_kota_yuzdesi(p_personelid integer, p_gerceklesen integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    hedef_Kota INTEGER;
    yuzde DECIMAL;
BEGIN
    SELECT "hedefKota" INTO hedef_Kota 
    FROM musteritemsilcileri 
    WHERE personelid = p_personelid;

    -- NULL veya sıfır kontrolü
    IF hedef_Kota IS NULL OR hedef_Kota = 0 THEN
        RETURN 0;
    END IF;

    -- Yüzde hesaplama
    yuzde := (p_gerceklesen * 100.0) / hedef_Kota;
    RETURN yuzde;
END;
$$;


ALTER FUNCTION public.hedef_kota_yuzdesi(p_personelid integer, p_gerceklesen integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 24783)
-- Name: maas_guncelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.maas_guncelle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Mesai ücreti değiştiyse, sabit ücreti güncelle
    IF NEW."mesaiUcret" <> OLD."mesaiUcret" THEN
        UPDATE public.personel
        SET "sabitUcret" = "sabitUcret" + (NEW."mesaiUcret" * 10)
        WHERE personelid = NEW.personelid;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.maas_guncelle() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 24844)
-- Name: maas_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.maas_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Maaşın 1000 TL'nin altında olup olmadığını kontrol et
    IF NEW."sabitUcret" < 1000 THEN
        RAISE EXCEPTION 'Maaş 1000 TL''nin altında olamaz!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.maas_kontrol() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 24812)
-- Name: maas_yuzde_artir(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.maas_yuzde_artir(personel_id integer, yuzde numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF yuzde <= 0 THEN
        RAISE EXCEPTION 'Yüzde değeri pozitif olmalıdır!';
    END IF;

    UPDATE personel
    SET "sabitUcret" = "sabitUcret" + ("sabitUcret" * yuzde / 100)
    WHERE "personelid" = personel_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Belirtilen ID''ye sahip çalışan bulunamadı!';
    END IF;
END;
$$;


ALTER FUNCTION public.maas_yuzde_artir(personel_id integer, yuzde numeric) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 24790)
-- Name: odeme_turu_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.odeme_turu_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.odemetur WHERE odemeturid = NEW."odemeTurid") THEN
        RAISE EXCEPTION 'Geçersiz ödeme türü!';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.odeme_turu_kontrol() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 24827)
-- Name: personel_sil(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.personel_sil(IN p_personelid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM musteritemsilcileri WHERE personelid = p_personelid;
    DELETE FROM calisan WHERE personelid = p_personelid;
    DELETE FROM yonetici WHERE personelid = p_personelid;
    DELETE FROM personel WHERE personelid = p_personelid;
END;
$$;


ALTER PROCEDURE public.personel_sil(IN p_personelid integer) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 24835)
-- Name: siparis_bilgilerini_goster(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparis_bilgilerini_goster() RETURNS TABLE(siparisid integer, musteriad character varying, musterisoyad character varying, siparisad character varying, siparismiktar integer, kargofirmaad character varying, urunad character varying, odemeturad character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.siparisid,
        m."musteriAd",
        m."musteriSoyad",
        s."siparisAd",
        s."siparisMiktar",
        k."kargoAd", -- Kargo Firması Adı
        u."urunad", -- Ürün Adı
        o."odemeturAd" -- Ödeme Türü Adı
    FROM
        public.siparis s
    JOIN
        public.musteri m ON s.musteriid = m.musteriid
    JOIN
        public.kargofirmasi k ON s."kargoFirmasiid" = k.kargoid
    JOIN
        public.deriurun u ON s.urunid = u.urunid
    JOIN
        public.odemetur o ON s."odemeTurid" = o.odemeturid;
END;
$$;


ALTER FUNCTION public.siparis_bilgilerini_goster() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 24830)
-- Name: siparis_toplam_degeri(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparis_toplam_degeri(p_siparisid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    toplam_deger NUMERIC;
BEGIN
    SELECT SUM(s."siparisMiktar" * u.satisfiyati) 
    INTO toplam_deger
    FROM siparis s
    JOIN deriurun u ON s.urunid = u.urunid
    WHERE s.siparisid = p_siparisid;

    IF toplam_deger IS NULL THEN
        RETURN 0;
    END IF;

    RETURN toplam_deger;
END;
$$;


ALTER FUNCTION public.siparis_toplam_degeri(p_siparisid integer) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 24839)
-- Name: stok_artir(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stok_artir() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Sipariş silindiğinde, sipariş miktarını stok miktarına ekle
    UPDATE public.deriurun
    SET stokmiktari = stokmiktari + OLD."siparisMiktar"
    WHERE urunid = OLD.urunid;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.stok_artir() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 24781)
-- Name: stok_guncelle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stok_guncelle() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Mevcut stok miktarını kontrol et
    IF (SELECT stokmiktari FROM public.deriurun WHERE urunid = NEW.urunid) < NEW."siparisMiktar" THEN
        RAISE EXCEPTION 'Yeterli stok yok!';
    ELSE
        -- Sipariş edilen ürünün stok miktarını azalt
        UPDATE public.deriurun
        SET stokmiktari = stokmiktari - NEW."siparisMiktar"
        WHERE urunid = NEW.urunid;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.stok_guncelle() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 24777)
-- Name: stok_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stok_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DECLARE
        mevcut_stok INTEGER;
    BEGIN
        -- Eğer INSERT işlemi yapılmışsa
        IF TG_OP = 'INSERT' THEN
            -- Yeni siparişin miktarı
            SELECT stokmiktari INTO mevcut_stok
            FROM public.deriurun
            WHERE urunid = NEW.urunid;

            IF NEW."siparisMiktar" > mevcut_stok THEN
                RAISE EXCEPTION 'Stok miktarı yetersiz! Mevcut stok: %, Sipariş Miktarı: %',
                    mevcut_stok, NEW."siparisMiktar";
            END IF;
        
        -- Eğer UPDATE işlemi yapılmışsa
        ELSIF TG_OP = 'UPDATE' THEN
            -- Güncellenen siparişin miktarı
            SELECT stokmiktari INTO mevcut_stok
            FROM public.deriurun
            WHERE urunid = NEW.urunid;

            IF NEW."siparisMiktar" > mevcut_stok THEN
                RAISE EXCEPTION 'Stok miktarı yetersiz! Mevcut stok: %, Sipariş Miktarı: %',
                    mevcut_stok, NEW."siparisMiktar";
            END IF;
        END IF;
        
        RETURN NEW;
    END;
END;
$$;


ALTER FUNCTION public.stok_kontrol() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 24788)
-- Name: temsilci_kontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temsilci_kontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.musteritemsilcileri WHERE personelid = NEW.temsilciid) THEN
        RAISE EXCEPTION 'Temsilci bulunamadı!';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.temsilci_kontrol() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 24834)
-- Name: toplam_maas_hesapla(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.toplam_maas_hesapla() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    toplam_maas NUMERIC;
BEGIN
    SELECT SUM("sabitUcret" * 2.3) INTO toplam_maas FROM personel;
    RETURN toplam_maas;
END;
$$;


ALTER FUNCTION public.toplam_maas_hesapla() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 24828)
-- Name: urun_zam_yap(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.urun_zam_yap(p_urunid integer, p_yuzde numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Yüzde kontrolü
    IF p_yuzde <= 0 THEN
        RAISE EXCEPTION 'Yüzde değeri pozitif olmalıdır!';
    END IF;

    -- Ürün fiyatını artır
    UPDATE deriurun
    SET satisfiyati = satisfiyati + (satisfiyati * p_yuzde / 100)
    WHERE urunid = p_urunid;

    -- Eğer ürün bulunamazsa 
    IF NOT FOUND THEN
        RAISE NOTICE 'Belirtilen ID % için ürün bulunamadı!', p_urunid;
    ELSE
        RAISE NOTICE 'Ürün ID % için fiyat % oranında artırıldı.', p_urunid, p_yuzde;
    END IF;
END;
$$;


ALTER FUNCTION public.urun_zam_yap(p_urunid integer, p_yuzde numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16735)
-- Name: personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personel (
    personelid integer NOT NULL,
    "personelAd" character varying(40) NOT NULL,
    "personelSoyad" character varying(40) NOT NULL,
    "sabitUcret" integer NOT NULL,
    "ePosta" character varying(40),
    "telefonNo" character varying(20),
    "girisTarih" date,
    "bulunduguSehir" integer NOT NULL,
    departman integer
);


ALTER TABLE public.personel OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16746)
-- Name: calisan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calisan (
    "mesaiUcret" integer,
    kidem integer NOT NULL
)
INHERITS (public.personel);


ALTER TABLE public.calisan OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24813)
-- Name: departman; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departman (
    departmanid integer NOT NULL,
    departmanad character varying(20) NOT NULL
);


ALTER TABLE public.departman OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16816)
-- Name: deriurun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deriurun (
    urunid integer NOT NULL,
    kategoriid integer NOT NULL,
    tabaklamaid integer NOT NULL,
    kaynakid integer NOT NULL,
    yuzeyid integer NOT NULL,
    stokmiktari integer NOT NULL,
    satisfiyati integer NOT NULL,
    urunad character varying(50)
);


ALTER TABLE public.deriurun OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16793)
-- Name: kargofirmasi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kargofirmasi (
    kargoid integer NOT NULL,
    "kargoAd" character varying(30) NOT NULL,
    "kargoUcret" integer NOT NULL
);


ALTER TABLE public.kargofirmasi OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16831)
-- Name: kategori; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kategori (
    kategoriid integer NOT NULL,
    "kategoriAd" character varying(50) NOT NULL
);


ALTER TABLE public.kategori OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16826)
-- Name: kaynak; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kaynak (
    "kaynakTurid" integer NOT NULL,
    "kaynakTurAd" character varying(50) NOT NULL
);


ALTER TABLE public.kaynak OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16761)
-- Name: musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri (
    musteriid integer NOT NULL,
    "musteriAd" character varying(40) NOT NULL,
    "musteriSoyad" character varying(40) NOT NULL,
    temsilciid integer NOT NULL,
    "bulunduguBolgeid" integer NOT NULL,
    "telefonNo" character varying(20),
    "ePostaAdresi" character varying(30)
);


ALTER TABLE public.musteri OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16766)
-- Name: musteribulundugubolge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteribulundugubolge (
    bolgeid integer NOT NULL,
    "bolgeAd" character varying(30) NOT NULL
);


ALTER TABLE public.musteribulundugubolge OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16756)
-- Name: musteritemsilcileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteritemsilcileri (
    "hedefKota" integer NOT NULL,
    "primOranı" integer NOT NULL
)
INHERITS (public.personel);


ALTER TABLE public.musteritemsilcileri OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16788)
-- Name: odemetur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.odemetur (
    odemeturid integer NOT NULL,
    "odemeturAd" character varying(40) NOT NULL
);


ALTER TABLE public.odemetur OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16730)
-- Name: sehir; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sehir (
    sehirid integer NOT NULL,
    "sehirAd" character varying(40) NOT NULL
);


ALTER TABLE public.sehir OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16783)
-- Name: siparis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparis (
    siparisid integer NOT NULL,
    musteriid integer NOT NULL,
    "siparisAd" character varying(50),
    "siparisMiktar" integer,
    "kargoFirmasiid" integer NOT NULL,
    urunid integer NOT NULL,
    "odemeTurid" integer NOT NULL
);


ALTER TABLE public.siparis OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16821)
-- Name: tabaklamatur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tabaklamatur (
    "tabaklamaTurid" integer NOT NULL,
    "tabaklamaTurAd" character varying(50) NOT NULL
);


ALTER TABLE public.tabaklamatur OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16751)
-- Name: yonetici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yonetici (
    pozisyon character varying(40) NOT NULL
)
INHERITS (public.personel);


ALTER TABLE public.yonetici OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16836)
-- Name: yuzeyislemesi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yuzeyislemesi (
    "islemeTurid" integer NOT NULL,
    "islemeTurAd" character varying(40) NOT NULL
);


ALTER TABLE public.yuzeyislemesi OWNER TO postgres;

--
-- TOC entry 3456 (class 0 OID 16746)
-- Dependencies: 216
-- Data for Name: calisan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calisan (personelid, "personelAd", "personelSoyad", "sabitUcret", "ePosta", "telefonNo", "girisTarih", "bulunduguSehir", "mesaiUcret", kidem, departman) FROM stdin;
22	Kerem	Çetin	5600	kerem.cetin@example.com	5552233444	2024-02-20	6	120	2	3
23	Sude	Yüce	5800	sude.yuce@example.com	5553344555	2024-01-15	1	110	4	1
24	Caner	Bozkurt	6000	caner.bozkurt@example.com	5554455666	2023-12-10	16	130	5	4
25	Melis	Koc	6100	melis.koc@example.com	5555566777	2023-11-05	35	115	3	5
26	Burak	Efe	4900	burak.efe@example.com	5556677888	2023-10-01	34	90	1	6
27	Selin	Aslan	5300	selin.aslan@example.com	5557788999	2023-09-20	6	95	2	7
28	Onur	Yılmaz	5800	onur.yilmaz@example.com	5558899000	2023-08-15	1	105	4	8
29	Deniz	Gül	6200	deniz.gul@example.com	5559900111	2023-07-01	16	125	5	1
30	Zeynep	Şentürk	5900	zeynep.senturk@example.com	5550011222	2023-06-15	35	115	3	2
31	Batuhan	Kaya	5700	batuhan.kaya@example.com	5551122333	2023-05-10	34	110	3	3
32	İpek	Arı	5500	ipek.ari@example.com	5552233444	2023-04-05	6	120	2	4
33	Emir	Uzun	6000	emir.uzun@example.com	5553344555	2023-03-01	1	125	5	5
34	Asya	Demir	6100	asya.demir@example.com	5554455666	2023-02-10	16	130	4	6
35	Rıza	Toprak	5400	riza.toprak@example.com	5555566777	2023-01-20	35	100	1	7
21	Ece	Aydın	5200	ece.aydin@example.com	05551112233	2024-03-01	34	100	3	2
\.


--
-- TOC entry 3469 (class 0 OID 24813)
-- Dependencies: 229
-- Data for Name: departman; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departman (departmanid, departmanad) FROM stdin;
1	ÜRETİM
2	Pazarlama
3	Finans\n
4	Muhasebe \n
5	İnsan kaynakları \n
6	Ar-Ge  \n
7	Halkla ilişkiler  \n
8	Hukuk   \n
\.


--
-- TOC entry 3464 (class 0 OID 16816)
-- Dependencies: 224
-- Data for Name: deriurun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deriurun (urunid, kategoriid, tabaklamaid, kaynakid, yuzeyid, stokmiktari, satisfiyati, urunad) FROM stdin;
8	6	1	8	3	248	650	Deri Ceket
9	1	3	9	2	89	800	El Yapımı Deri Çanta
10	3	2	10	1	128	350	Deri Portföy
11	2	1	1	4	59	850	Deri Etek
12	4	3	2	3	68	920	Deri Elbise
13	3	2	3	2	179	500	Deri Otomobil Koltuk Kılıfı
14	5	1	4	4	108	450	Deri Ayakkabı
15	6	4	5	1	74	620	Deri Çanta Seti
16	7	3	6	2	198	550	Süet Ayakkabı
17	8	1	7	3	219	700	Süet Ceket
18	5	2	8	4	48	480	Deri El Çantası
19	4	3	9	1	179	500	Deri Sırt Çantası
20	2	1	10	2	158	600	Deri Portföy Çantası
1	1	1	1	1	99	1200	Klasik Deri Ceket
2	7	3	4	4	100	123456	AYAKKABI
3	2	2	3	1	199	550	Deri Koltuk
4	3	1	4	3	178	700	Deri Çanta
21	1	1	1	1	2	2	DENEME EKLEME
6	6	4	4	4	100	11	GÜNCELLENECEK
\.


--
-- TOC entry 3463 (class 0 OID 16793)
-- Dependencies: 223
-- Data for Name: kargofirmasi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kargofirmasi (kargoid, "kargoAd", "kargoUcret") FROM stdin;
1	Aras Kargo	15
2	Yurtiçi Kargo	18
3	MNG Kargo	20
4	PTT Kargo	10
5	Sürat Kargo	12
6	UPS	25
7	DHL	30
8	FedEx	35
9	KargoNet	22
10	TNT	28
\.


--
-- TOC entry 3467 (class 0 OID 16831)
-- Dependencies: 227
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kategori (kategoriid, "kategoriAd") FROM stdin;
1	El İşi
2	Giyim
3	Döşeme
4	Spor Ekipmanları
5	Sanayi Ürünleri
6	Yapı Malzemeleri
7	Elektronik
8	Gıda
9	Mobilya
10	Otomotiv
11	Teknolojik Ürünler
12	Züccaciye
13	Hobi Ürünleri
14	Sağlık Ürünleri
15	Ev Gereçleri
\.


--
-- TOC entry 3466 (class 0 OID 16826)
-- Dependencies: 226
-- Data for Name: kaynak; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kaynak ("kaynakTurid", "kaynakTurAd") FROM stdin;
1	Dana Derisi
2	Yılan Derisi
3	Sentetik Deri
4	Kuzu Derisi
5	Tavşan Derisi
6	Yumuşak Deri
7	Koyun Derisi
8	Timsah Derisi
9	Vegan Deri
10	Sığır Derisi
\.


--
-- TOC entry 3459 (class 0 OID 16761)
-- Dependencies: 219
-- Data for Name: musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musteri (musteriid, "musteriAd", "musteriSoyad", temsilciid, "bulunduguBolgeid", "telefonNo", "ePostaAdresi") FROM stdin;
1	Ahmet	Yılmaz	36	1	0543 123 45 67	ahmet.yilmaz@example.com
2	Mehmet	Kaya	37	2	0543 234 56 78	mehmet.kaya@example.com
3	Ayşe	Çelik	38	3	0543 345 67 89	ayse.celik@example.com
4	Fatma	Demir	39	4	0543 456 78 90	fatma.demir@example.com
5	Ali	Kara	40	1	0543 567 89 01	ali.kara@example.com
6	Veli	Gül	41	2	0543 678 90 12	veli.gul@example.com
7	Emine	Özdemir	42	3	0543 789 01 23	emine.ozdemir@example.com
8	Ahmet	Berk	43	4	0543 890 12 34	ahmet.berk@example.com
9	Murat	Aslan	44	1	0543 901 23 45	murat.aslan@example.com
10	Mehmet	Şahin	45	2	0543 012 34 56	mehmet.sahin@example.com
11	Seda	Yıldız	46	3	0543 123 45 67	seda.yildiz@example.com
12	Zeynep	Baysal	47	4	0543 234 56 78	zeynep.baysal@example.com
13	Kemal	Can	48	1	0543 345 67 89	kemal.can@example.com
14	Cem	Ekin	49	2	0543 456 78 90	cem.ekin@example.com
15	Eda	Güven	50	3	0543 567 89 01	eda.guven@example.com
16	Ömer	Yılmaz	36	4	0543 678 90 12	omer.yilmaz@example.com
17	Neslihan	Duman	37	1	0543 789 01 23	neslihan.duman@example.com
18	Berk	Koç	38	2	0543 890 12 34	berk.koc@example.com
19	Murat	Öztürk	39	3	0543 901 23 45	murat.ozturk@example.com
20	Yasemin	Karaca	40	4	0543 012 34 56	yasemin.karaca@example.com
\.


--
-- TOC entry 3460 (class 0 OID 16766)
-- Dependencies: 220
-- Data for Name: musteribulundugubolge; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musteribulundugubolge (bolgeid, "bolgeAd") FROM stdin;
4	Afrika
3	Asya
2	Avrupa
1	Amerika
\.


--
-- TOC entry 3458 (class 0 OID 16756)
-- Dependencies: 218
-- Data for Name: musteritemsilcileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.musteritemsilcileri (personelid, "personelAd", "personelSoyad", "sabitUcret", "ePosta", "telefonNo", "girisTarih", "bulunduguSehir", "hedefKota", "primOranı", departman) FROM stdin;
48	İrem	Güler	5500	irem.guler@example.com	5553344555	2023-05-15	1	1000	8	5
49	Onur	Uçar	5800	onur.ucar@example.com	5554455666	2023-04-10	16	1300	7	6
50	Buse	Çetin	6200	buse.cetin@example.com	5555566777	2023-03-05	35	1200	9	7
36	Elif	Çakır	5400	elif.cakir@example.com	5551122333	2024-05-15	34	10000	8	1
37	Murat	Güzel	5600	murat.guzel@example.com	5552233444	2024-04-10	6	15000	10	2
38	Ali	Demir	5700	ali.demir@example.com	5553344555	2024-03-05	1	12000	7	3
39	Ayşe	Kılıç	5900	ayse.kilic@example.com	5554455666	2024-02-25	16	1100	9	4
40	Fatma	Yıldız	6000	fatma.yildiz@example.com	5555566777	2024-01-20	35	1300	6	5
41	Can	Toprak	5500	can.toprak@example.com	5556677888	2023-12-15	34	950	5	6
42	Zeynep	Büyük	5300	zeynep.buyuk@example.com	5557788999	2023-11-10	6	1400	8	7
43	Emir	Kara	5600	emir.kara@example.com	5558899000	2023-10-05	1	1150	7	8
44	Burak	Arslan	5800	burak.arslan@example.com	5559900111	2023-09-01	16	1250	9	1
45	Eda	Sarı	6000	eda.sari@example.com	5550011222	2023-08-20	35	1350	10	2
46	Selin	Bozkurt	5700	selin.bozkurt@example.com	5551122333	2023-07-10	34	1250	6	3
47	Berk	Öztürk	5900	berk.ozturk@example.com	5552233444	2023-06-25	6	950	5	4
\.


--
-- TOC entry 3462 (class 0 OID 16788)
-- Dependencies: 222
-- Data for Name: odemetur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.odemetur (odemeturid, "odemeturAd") FROM stdin;
1	Nakit
2	Kredi Kartı
3	Banka Havalesi
4	Kapıda Ödeme
5	Paypal
6	EFT
7	Kredi Kartı ile Taksitli
8	Mobil Ödeme
9	Bitcoin
10	Alışveriş Kredisi
\.


--
-- TOC entry 3455 (class 0 OID 16735)
-- Dependencies: 215
-- Data for Name: personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personel (personelid, "personelAd", "personelSoyad", "sabitUcret", "ePosta", "telefonNo", "girisTarih", "bulunduguSehir", departman) FROM stdin;
\.


--
-- TOC entry 3454 (class 0 OID 16730)
-- Dependencies: 214
-- Data for Name: sehir; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sehir (sehirid, "sehirAd") FROM stdin;
1	Adana
2	Adıyaman
3	Afyon
4	Ağrı
5	Amasya
6	Ankara
7	Antalya
8	Artvin
9	Aydın
10	Balıkesir
11	Bilecik
12	Bingöl
13	Bitlis
14	Bolu
15	Burdur
16	Bursa
17	Çanakkale
18	Çankırı
19	Çorum
20	Denizli
21	Diyarbakır
22	Edirne
23	Elazığ
24	Erzincan
25	Erzurum
26	Eskişehir
27	Gaziantep
28	Giresun
29	Gümüşhane
30	Hakkari
31	Hatay
32	Iğdır
33	Mersin
34	Isparta
35	İstanbul
36	İzmir
37	Kahramanmaraş
38	Karabük
39	Karaman
40	Kastamonu
41	Kayseri
42	Kırıkkale
43	Kırklareli
44	Kırşehir
45	Kocaeli
46	Konya
47	Kütahya
48	Malatya
49	Manisa
50	Mardin
\.


--
-- TOC entry 3461 (class 0 OID 16783)
-- Dependencies: 221
-- Data for Name: siparis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.siparis (siparisid, musteriid, "siparisAd", "siparisMiktar", "kargoFirmasiid", urunid, "odemeTurid") FROM stdin;
4	4	Süet Ceket	102	4	4	4
2	2	Deriden Yapılmış Çanta	2	2	2	2
3	3	Yılan Derisi Çanta	1	3	3	3
1	1	Deri Ceket	0	1	1	1
\.


--
-- TOC entry 3465 (class 0 OID 16821)
-- Dependencies: 225
-- Data for Name: tabaklamatur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tabaklamatur ("tabaklamaTurid", "tabaklamaTurAd") FROM stdin;
1	Derin Tabaklama
2	Yüzey Tabaklama
3	Boya Tabaklaması
4	Sünger Tabaklama
5	Yağlı Tabaklama
6	Su Bazlı Tabaklama
7	Kimyasal Tabaklama
8	Isıl İşlem Tabaklama
\.


--
-- TOC entry 3457 (class 0 OID 16751)
-- Dependencies: 217
-- Data for Name: yonetici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yonetici (personelid, "personelAd", "personelSoyad", "sabitUcret", "ePosta", "telefonNo", "girisTarih", "bulunduguSehir", pozisyon, departman) FROM stdin;
3	Mehmet	Demir	5500	mehmet.demir@example.com	5553456789	2023-11-10	6	Uzman	3
4	Fatma	Çelik	5800	fatma.celik@example.com	5554567890	2023-10-20	1	Uzman Yardımcısı	4
6	Elif	Yıldırım	5000	elif.yildirim@example.com	5556789012	2024-03-01	34	Teknisyen	5
7	Mustafa	Arslan	7000	mustafa.arslan@example.com	5557890123	2024-04-15	6	Danışman	6
8	Zeynep	Polat	4800	zeynep.polat@example.com	5558901234	2023-09-05	35	Analist	7
9	Burak	Taş	5200	burak.tas@example.com	5559012345	2023-08-12	1	Mühendis	1
10	Hale	Güneş	5600	hale.gunes@example.com	5550123456	2023-07-01	16	Teknisyen	8
11	Kemal	Kurt	6100	kemal.kurt@example.com	5551111222	2023-06-15	34	Planlama Uzmanı	3
12	Derya	Akın	5900	derya.akin@example.com	5552222333	2023-05-20	6	Proje Yöneticisi	4
13	Hakan	Turan	6400	hakan.turan@example.com	5553333444	2023-04-10	35	Teknik Lider	2
14	Gizem	Şahin	5500	gizem.sahin@example.com	5554444555	2023-03-12	1	Sistem Analisti	1
15	Emre	Deniz	5800	emre.deniz@example.com	5555555666	2023-02-20	16	Veri Analisti	6
16	Ceren	Ünal	5300	ceren.unal@example.com	5556666777	2023-01-15	34	Yazılım Geliştirici	5
17	Oğuz	Kaya	6000	oguz.kaya@example.com	5557777888	2022-12-10	6	Veritabanı Uzmanı	8
18	Aslı	Eren	5600	asli.eren@example.com	5558888999	2022-11-05	35	İK Uzmanı	7
19	Can	Kılıç	5400	can.kilic@example.com	5559999000	2022-10-20	1	Satış Temsilcisi	4
20	Deniz	Bulut	6200	deniz.bulut@example.com	5550000111	2022-09-15	16	Proje Koordinatörü	2
2	Ayşe	Kara	12000	ayse.kara@example.com	5552345678	2023-12-15	35	Müdür Yardımcısı	2
1	Ali	Yılmaz	11000	ali.yilmaz@example.com	5551234567	2024-01-01	34	Müdür	1
\.


--
-- TOC entry 3468 (class 0 OID 16836)
-- Dependencies: 228
-- Data for Name: yuzeyislemesi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yuzeyislemesi ("islemeTurid", "islemeTurAd") FROM stdin;
1	Pürüzsüz Deri
2	Süet Deri
3	Doğal Deri
4	Boya Derisi
5	Parlatılmış Deri
6	Yanmış Deri
7	Kadife Deri
8	Sarımsak Derisi
9	Krem Derisi
10	Mat Deri
\.


--
-- TOC entry 3253 (class 2606 OID 16750)
-- Name: calisan calisan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_pkey PRIMARY KEY (personelid);


--
-- TOC entry 3289 (class 2606 OID 24817)
-- Name: departman departman_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departman
    ADD CONSTRAINT departman_pkey PRIMARY KEY (departmanid);


--
-- TOC entry 3275 (class 2606 OID 16820)
-- Name: deriurun deriurun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deriurun
    ADD CONSTRAINT deriurun_pkey PRIMARY KEY (urunid);


--
-- TOC entry 3273 (class 2606 OID 16797)
-- Name: kargofirmasi kargofirmasi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kargofirmasi
    ADD CONSTRAINT kargofirmasi_pkey PRIMARY KEY (kargoid);


--
-- TOC entry 3285 (class 2606 OID 16835)
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (kategoriid);


--
-- TOC entry 3283 (class 2606 OID 16830)
-- Name: kaynak kaynak_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kaynak
    ADD CONSTRAINT kaynak_pkey PRIMARY KEY ("kaynakTurid");


--
-- TOC entry 3257 (class 2606 OID 16760)
-- Name: musteritemsilcileri musteriTemsicileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteritemsilcileri
    ADD CONSTRAINT "musteriTemsicileri_pkey" PRIMARY KEY (personelid);


--
-- TOC entry 3261 (class 2606 OID 16765)
-- Name: musteri musteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT musteri_pkey PRIMARY KEY (musteriid);


--
-- TOC entry 3263 (class 2606 OID 16770)
-- Name: musteribulundugubolge musteribulundugubolge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteribulundugubolge
    ADD CONSTRAINT musteribulundugubolge_pkey PRIMARY KEY (bolgeid);


--
-- TOC entry 3271 (class 2606 OID 16792)
-- Name: odemetur odemetur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odemetur
    ADD CONSTRAINT odemetur_pkey PRIMARY KEY (odemeturid);


--
-- TOC entry 3251 (class 2606 OID 16739)
-- Name: personel personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT personel_pkey PRIMARY KEY (personelid);


--
-- TOC entry 3248 (class 2606 OID 16734)
-- Name: sehir sehir_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sehir
    ADD CONSTRAINT sehir_pkey PRIMARY KEY (sehirid);


--
-- TOC entry 3269 (class 2606 OID 16787)
-- Name: siparis siparis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT siparis_pkey PRIMARY KEY (siparisid);


--
-- TOC entry 3281 (class 2606 OID 16825)
-- Name: tabaklamatur tabaklamatur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tabaklamatur
    ADD CONSTRAINT tabaklamatur_pkey PRIMARY KEY ("tabaklamaTurid");


--
-- TOC entry 3255 (class 2606 OID 16755)
-- Name: yonetici yonetici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yonetici
    ADD CONSTRAINT yonetici_pkey PRIMARY KEY (personelid);


--
-- TOC entry 3287 (class 2606 OID 16840)
-- Name: yuzeyislemesi yuzeyislemesi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yuzeyislemesi
    ADD CONSTRAINT yuzeyislemesi_pkey PRIMARY KEY ("islemeTurid");


--
-- TOC entry 3258 (class 1259 OID 16776)
-- Name: fki_bolge_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_bolge_foreign ON public.musteri USING btree ("bulunduguBolgeid");


--
-- TOC entry 3264 (class 1259 OID 16809)
-- Name: fki_kargo_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_kargo_foreign ON public.siparis USING btree ("kargoFirmasiid");


--
-- TOC entry 3276 (class 1259 OID 16846)
-- Name: fki_kategori_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_kategori_foreign ON public.deriurun USING btree (kategoriid);


--
-- TOC entry 3277 (class 1259 OID 16852)
-- Name: fki_kaynak_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_kaynak_foreign ON public.deriurun USING btree (kaynakid);


--
-- TOC entry 3265 (class 1259 OID 16803)
-- Name: fki_musteri_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_musteri_foreign ON public.siparis USING btree (musteriid);


--
-- TOC entry 3266 (class 1259 OID 16815)
-- Name: fki_odeme_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_odeme_foreign ON public.siparis USING btree ("odemeTurid");


--
-- TOC entry 3249 (class 1259 OID 16745)
-- Name: fki_sehir_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_sehir_foreign ON public.personel USING btree ("bulunduguSehir");


--
-- TOC entry 3278 (class 1259 OID 16864)
-- Name: fki_tabaklama_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_tabaklama_foreign ON public.deriurun USING btree (tabaklamaid);


--
-- TOC entry 3259 (class 1259 OID 16782)
-- Name: fki_temsilci_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_temsilci_foreign ON public.musteri USING btree (temsilciid);


--
-- TOC entry 3267 (class 1259 OID 16870)
-- Name: fki_urun_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_urun_foreign ON public.siparis USING btree (urunid);


--
-- TOC entry 3279 (class 1259 OID 16858)
-- Name: fki_yuzeyisleme_foreign; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_yuzeyisleme_foreign ON public.deriurun USING btree (yuzeyid);


--
-- TOC entry 3303 (class 2620 OID 24846)
-- Name: calisan maas_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER maas_kontrol_trigger BEFORE INSERT OR UPDATE ON public.calisan FOR EACH ROW EXECUTE FUNCTION public.maas_kontrol();


--
-- TOC entry 3306 (class 2620 OID 24848)
-- Name: musteritemsilcileri maas_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER maas_kontrol_trigger BEFORE INSERT OR UPDATE ON public.musteritemsilcileri FOR EACH ROW EXECUTE FUNCTION public.maas_kontrol();


--
-- TOC entry 3302 (class 2620 OID 24845)
-- Name: personel maas_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER maas_kontrol_trigger BEFORE INSERT OR UPDATE ON public.personel FOR EACH ROW EXECUTE FUNCTION public.maas_kontrol();


--
-- TOC entry 3305 (class 2620 OID 24847)
-- Name: yonetici maas_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER maas_kontrol_trigger BEFORE INSERT OR UPDATE ON public.yonetici FOR EACH ROW EXECUTE FUNCTION public.maas_kontrol();


--
-- TOC entry 3308 (class 2620 OID 24791)
-- Name: siparis odeme_turu_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER odeme_turu_kontrol_trigger BEFORE INSERT OR UPDATE ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.odeme_turu_kontrol();


--
-- TOC entry 3309 (class 2620 OID 24782)
-- Name: siparis siparis_stok_guncelle_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER siparis_stok_guncelle_trigger AFTER INSERT ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.stok_guncelle();


--
-- TOC entry 3310 (class 2620 OID 24840)
-- Name: siparis stok_artir_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER stok_artir_trigger AFTER DELETE ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.stok_artir();


--
-- TOC entry 3311 (class 2620 OID 24778)
-- Name: siparis stok_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER stok_kontrol_trigger BEFORE INSERT OR UPDATE ON public.siparis FOR EACH ROW EXECUTE FUNCTION public.stok_kontrol();


--
-- TOC entry 3307 (class 2620 OID 24789)
-- Name: musteri temsilci_kontrol_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER temsilci_kontrol_trigger BEFORE INSERT ON public.musteri FOR EACH ROW EXECUTE FUNCTION public.temsilci_kontrol();


--
-- TOC entry 3304 (class 2620 OID 24786)
-- Name: calisan tr_maas_guncelle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_maas_guncelle AFTER UPDATE OF "mesaiUcret" ON public.calisan FOR EACH ROW EXECUTE FUNCTION public.maas_guncelle();


--
-- TOC entry 3292 (class 2606 OID 16771)
-- Name: musteri bolge_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT bolge_foreign FOREIGN KEY ("bulunduguBolgeid") REFERENCES public.musteribulundugubolge(bolgeid) NOT VALID;


--
-- TOC entry 3290 (class 2606 OID 24818)
-- Name: personel departman_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT departman_foreign FOREIGN KEY (departman) REFERENCES public.departman(departmanid) NOT VALID;


--
-- TOC entry 3294 (class 2606 OID 16804)
-- Name: siparis kargo_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT kargo_foreign FOREIGN KEY ("kargoFirmasiid") REFERENCES public.kargofirmasi(kargoid) NOT VALID;


--
-- TOC entry 3298 (class 2606 OID 16841)
-- Name: deriurun kategori_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deriurun
    ADD CONSTRAINT kategori_foreign FOREIGN KEY (kategoriid) REFERENCES public.kategori(kategoriid) NOT VALID;


--
-- TOC entry 3299 (class 2606 OID 16847)
-- Name: deriurun kaynak_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deriurun
    ADD CONSTRAINT kaynak_foreign FOREIGN KEY (kaynakid) REFERENCES public.kaynak("kaynakTurid") NOT VALID;


--
-- TOC entry 3295 (class 2606 OID 16798)
-- Name: siparis musteri_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT musteri_foreign FOREIGN KEY (musteriid) REFERENCES public.musteri(musteriid) NOT VALID;


--
-- TOC entry 3296 (class 2606 OID 16810)
-- Name: siparis odeme_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT odeme_foreign FOREIGN KEY ("odemeTurid") REFERENCES public.odemetur(odemeturid) NOT VALID;


--
-- TOC entry 3291 (class 2606 OID 16740)
-- Name: personel sehir_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT sehir_foreign FOREIGN KEY ("bulunduguSehir") REFERENCES public.sehir(sehirid) NOT VALID;


--
-- TOC entry 3300 (class 2606 OID 16859)
-- Name: deriurun tabaklama_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deriurun
    ADD CONSTRAINT tabaklama_foreign FOREIGN KEY (tabaklamaid) REFERENCES public.tabaklamatur("tabaklamaTurid") NOT VALID;


--
-- TOC entry 3293 (class 2606 OID 16777)
-- Name: musteri temsilci_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri
    ADD CONSTRAINT temsilci_foreign FOREIGN KEY (temsilciid) REFERENCES public.musteritemsilcileri(personelid) NOT VALID;


--
-- TOC entry 3297 (class 2606 OID 16865)
-- Name: siparis urun_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis
    ADD CONSTRAINT urun_foreign FOREIGN KEY (urunid) REFERENCES public.deriurun(urunid) NOT VALID;


--
-- TOC entry 3301 (class 2606 OID 16853)
-- Name: deriurun yuzeyisleme_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deriurun
    ADD CONSTRAINT yuzeyisleme_foreign FOREIGN KEY (yuzeyid) REFERENCES public.yuzeyislemesi("islemeTurid") NOT VALID;


-- Completed on 2024-12-18 13:02:07

--
-- PostgreSQL database dump complete
--

