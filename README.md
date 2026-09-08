# Abozor Challenge (Flutter)

`bright-recollections.lovable.app` prototipining Flutter'dagi nusxasi:
bosh sahifa, KONKURS banneri → Abozor Challenge, AI Yordamchi (narxlash chat),
profil va lotareya sahifasi.

## 1. Ishga tushirish

Loyihada faqat `lib/`, `pubspec.yaml` va `assets/` bor — native papkalar (android/ios/web)
generatsiya qilinishi kerak:

```bash
cd ~/Desktop/abozor_challenge
flutter create . --org uz.abozor --project-name abozor_challenge --platforms=android,ios,web
flutter pub get
flutter run
```

> `flutter create .` mavjud `lib/main.dart` va `pubspec.yaml` ni o'chirmaydi,
> faqat yetishmayotgan platforma papkalarini qo'shadi.

## 2. Rasmlar

`assets/images/` ichida placeholder fayllar turibdi. Saytdagi asl rasmlarni olish uchun
(Mac terminalida, ushbu papkada):

```bash
cd ~/Desktop/abozor_challenge/assets/images
curl -o hero-car.jpg      https://bright-recollections.lovable.app/assets/hero-car-Cu8nhcjI.jpg
curl -o car-cobalt.jpg    https://bright-recollections.lovable.app/assets/car-cobalt-BC3zTX7v.jpg
curl -o car-tracker.jpg   https://bright-recollections.lovable.app/assets/car-tracker-D7a4t0pc.jpg
curl -o car-gentra.jpg    https://bright-recollections.lovable.app/assets/car-gentra-CKQWK1kG.jpg
curl -o prize-iphone.jpg  https://bright-recollections.lovable.app/assets/prize-iphone-DAuSCVyr.jpg
curl -o prize-airpods.jpg https://bright-recollections.lovable.app/assets/prize-airpods-C-EQisKk.jpg
curl -o prize-scooter.jpg https://bright-recollections.lovable.app/assets/prize-scooter-CMzLcXna.jpg
```

Rasm topilmasa ilova buzilmaydi — `AssetImageBox` placeholder chizadi.

## 3. Struktura

```
lib/
  app/                 # tema, MaterialApp, pastki navigatsiyali karkas
  core/                # umumiy widget va utilitalar (narx formati, invite, bottom nav)
  features/
    home/              # bosh sahifa va uning bloklari
    challenge/         # Abozor Challenge: 8 mashina, savol, to'g'ri javob ekrani
    ai_valuation/      # AI narxlash chat (AiChatBloc + ValuationRepository)
    profile/           # profil sahifasi
```

State management: `flutter_bloc` (ChallengeBloc, AiChatBloc).

## 4. Sayt bilan mosligi

| Sayt | Flutter |
|---|---|
| Ranglar (`oklch` CSS o'zgaruvchilari) | `AppColors` (hex'ga o'girilgan) |
| Manrope shrifti | `google_fonts` → `GoogleFonts.manropeTextTheme` |
| `--radius: 1.25rem` | `AppRadius.lg = 20` |
| 8 ta mashina + narx variantlari | `ChallengeData.cars` (bir-bir ko'chirilgan) |
| Sovrinlar | `ChallengeData.prizes` (1 ta oliy + 6 ta oddiy) |
| AI savollari ketma-ketligi | `kAiQuestions` |
| Bottom nav'dagi 3 ta bo'lim bosh sahifaga olib boradi | `MainShell._onTap` |

## 5. Saytdan farqi (ataylab)

- **Lotareya / kupon g'oyasi olib tashlangan** — profil kartasi, `/lotareya` sahifasi,
  header'dagi kupon hisoblagichi va kupon saqlash logikasi yo'q.
- **To'g'ri javob alohida ekran** (`ChallengeSuccessPage`) — pop-up emas: konfetti,
  belgi sakrab chiqishi va matn/tugmalarning ketma-ket paydo bo'lishi bilan ochiladi.
- **AI chati** — ketma-ket kelgan bot xabarlari birin-ketin yoziladi (bir vaqtda emas);
  matn harfma-harf chiqadi (`TypingText`).
- **"Bilmayapsizmi?"** bosilganda mashina kartasi kichrayib tepada pin bo'ladi,
  chat qolgan balandlikni egallaydi.
- **Konkurs oqimi**: avval sovrinlar ro'yxati (scroll), keyin mashina, keyin narx savoli.
  Oliy bosh sovrin (iPhone 17 Pro Max) uchun qo'shimcha shart — taklif havolasini ulashish.
  "1000 so'm" g'oyasi olib tashlangan.

- **AI baholash** — saytda server funksiyasi (LLM). Bu yerda `MockValuationRepository`
  (offline, deterministik). Real API uchun `ValuationRepository` ni implement qiling
  va `main.dart` dagi bitta qatorni almashtiring.
- **Do'stni taklif qilish** — saytda tugma hech narsa qilmaydi. Bu yerda referal havola
  clipboard'ga nusxalanadi (`InviteHelper`), real kod backend'dan kelishi kerak.
- **USD kursi** — saytda ochiq emas; `PriceFormatter.usdRate = 12800` (bitta joyda).

## 6. Prototipdagi ochiq savollar (backend kerak)

- Bitta mashinani cheksiz qayta yechish mumkin (limit qo'yilmagan).
- Referal "do'st akkauntini faollashtirdi" hodisasi yo'q — havola faqat nusxalanadi.
- Oliy sovrin sharti hozir faqat frontendda tekshiriladi (ulashish fakti backendda tasdiqlanishi kerak).
