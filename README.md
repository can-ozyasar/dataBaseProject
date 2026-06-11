# Database Project

Veritabanı arayüzü ve PL/pgSQL çalışmaları içeren ders/proje reposu.

## Bu Repo Ne İçin Var?
Veritabanı tasarımı, PL/pgSQL ve uygulama arayüzü entegrasyonunu çalışmak için oluşturuldu.

Bu README'nin amacı; repoya ilk kez gelen birinin projenin neden açıldığını, içinde ne bulunduğunu ve nereden başlaması gerektiğini hızlıca anlamasını sağlamaktır.

## İçerik ve Kapsam
Bu repoda öne çıkan içerikler şunlardır:
- PostgreSQL/PLpgSQL odağı
- .NET arayüz projesi
- Veritabanı tasarımı ve uygulama entegrasyonu pratiği
- .NET solution/proje dosyaları ve katmanlı uygulama yapısı

## Kimler İçin Faydalı?
Tam yığın uygulama mimarisini, modül ayrımını veya servis-UI ilişkisini incelemek isteyenler için uygundur.

## Kullanılan Teknolojiler
- PLpgSQL
- .NET
- C#
- PostgreSQL / SQL

## Kurulum
```bash
dotnet restore "veriTabaniArayuzu/dataBaseOdev.sln"
```

## Çalıştırma
```bash
dotnet build "veriTabaniArayuzu/dataBaseOdev.sln"
```

## Önemli Dosyalar
- `veriTabaniArayuzu/dataBaseOdev.csproj`
- `veriTabaniArayuzu/dataBaseOdev.sln`

## Proje Yapısı
- `veriTabaniArayuzu` - 12 dosya
- `DatabaseRapor.pdf` - 1 dosya
- `dataBaseProjectG231210009.pdf` - 1 dosya
- `dataBasediagrami.png` - 1 dosya
- `veritabani_dump.sql` - 1 dosya

## Geliştirme Notları
- README içeriği, repodaki mevcut dosya yapısı ve proje açıklamasına göre düzenlenmiştir.
- Yeni modül, veri seti veya servis eklendiğinde kurulum/çalıştırma bölümlerini güncelleyin.
- .NET projelerinde solution yapısı değişirse `dotnet restore` ve `dotnet build` adımlarını yeniden doğrulayın.

## Lisans
Bu repoda açık bir lisans dosyası yoksa tüm haklar varsayılan olarak proje sahibine aittir. Paylaşım veya kullanım koşulları için repo sahibine danışın.
