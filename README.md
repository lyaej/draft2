# 🇵🇭 TaGaLook — Tagalog Translator App

Ang tagaLook ay isang aplikasyon na **nagsasalin ng anumang wika sa Filipino / Tagalog** gamit lamang ang mga kamera, mikropono, at teklado ng mga selyular na aparato.

---

## Mga Tampok

### Live Camera Scan
Itutok ang iyong camera sa kahit anong text — tanda, libro, menu, label — at awtomatiko itong **mababasa at isasalin sa Tagalog** nang real time. Walang button na pipindutin. Itutok lang at basahin.

### Text Translate
Mag-type o mag-paste ng kahit anong text sa kahit anong wika at makakuha agad ng salin sa Tagalog. Sumusuporta ng mahigit 50 wika kasama na ang Ingles, Hapon, Koreano, Tsino, Espanyol, Pranses, Arabik, at marami pa.

### Voice Translate
Magsalita sa kahit anong wika at pakikinggan ng TaGaLook, makikilala ang sinabi mo, at isasalin ito sa Tagalog. Maganda para sa pakikipag-usap, pag-aaral, at paglalakbay.

### Text-to-Speech
Bawat salin ay maaaring basahin nang malakas sa Filipino gamit ang built-in na text-to-speech. I-tap ang speaker button para marinig ang salin sa Tagalog.

### History
Bawat salin ay awtomatikong sine-save. Tingnan ang iyong mga nakaraang salin anumang oras — kasama ang orihinal na text, nadetect na wika, uri ng pinagmulan (camera, text, o boses), at petsa at oras. Maaari mo ring kopyahin o pakinggan ang kahit anong nakaraang salin.

 
---

## Paano Gamitin

### Camera Scan
1. I-tap ang **SCAN** sa home screen
2. Itutok ang camera sa kahit anong text
3. Lalabas ang salin awtomatiko sa ibaba

### Text Translate
1. I-tap ang **TEXT TRANSLATE** sa home screen
2. Mag-type o mag-paste ng text
3. I-tap ang **I-TRANSLATE SA TAGALOG**
4. I-tap ang para marinig ito

### Voice Translate
1. I-tap ang **VOICE TRANSLATE** sa home screen
2. I-tap ang microphone button
3. Magsalita sa kahit anong wika
4. Lalabas ang salin awtomatiko

### History
1. I-tap ang icon sa kanang sulok sa baba ng home screen
2. Tingnan ang lahat ng nakaraang salin
3. I-tap ang para kopyahin o para pakinggan

---

## Kinakailangan

- Android 8.0 (Oreo) o mas bago
- Koneksyon sa internet (unang beses lang, para sa ML Kit model download)
- Camera permission (para sa Scan feature)
- Microphone permission (para sa Voice Translate feature)

---

## Ginawa Gamit Ang

- **Flutter / Dart** — cross-platform na UI framework
- **Google ML Kit** — on-device OCR, language detection, at translation
- **flutter_tts** — text-to-speech sa Filipino
- **speech_to_text** — voice recognition
- **camera** — live camera preview
- **shared_preferences** — lokal na pag-iimbak ng history

---

## Estruktura ng Proyekto

```
lib/
├── main.dart                     ← Panimula ng app
├── app_colors.dart               ← Tema ng kulay
├── models/
│   └── history_item.dart         ← Mga data model
├── services/
│   ├── api_service.dart          ← ML Kit OCR + Translation
│   ├── history_manager.dart      ← I-save/load ang history
│   └── tts_manager.dart          ← Text-to-speech
├── screens/
│   ├── main_screen.dart          ← Home screen
│   ├── scan_screen.dart          ← Live camera scan
│   ├── text_translate_screen.dart
│   ├── voice_translate_screen.dart
│   └── history_screen.dart
└── widgets/
    └── history_card.dart         ← History list item
```
 
---

*TaGaLook — Para sa mga Pilipino, saan ka man naroroon.*