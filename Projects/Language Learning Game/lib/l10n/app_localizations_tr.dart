// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get helloWorld => 'Merhaba Dünya!';

  @override
  String get languageSelection => 'Dil Seçimi';

  @override
  String get languageSelectionDescription =>
      'Lütfen ana dilinizi ve öğrenmek istediğiniz dili seçin. Bu ayarları daha sonra Ayarlar menüsünden değiştirebilirsiniz.';

  @override
  String get myNativeLanguage => 'Ana Dilim';

  @override
  String get languageIWantToLearn => 'Öğrenmek İstediğim Dil';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get pleaseSelectBothLanguages => 'Lütfen her iki dili de seçin.';

  @override
  String get languagesMustBeDifferent =>
      'Ana dil ve öğrenilecek dil farklı olmalıdır.';

  @override
  String get languageSettings => 'Dil Ayarları';

  @override
  String get nativeLanguage => 'Ana Dil';

  @override
  String get nativeLanguageDescription =>
      'İpuçlarının hangi dilde gösterileceğini seçin.';

  @override
  String get targetLanguage => 'Öğrenilecek Dil';

  @override
  String get targetLanguageDescription =>
      'Hangi dili öğrenmek istediğinizi seçin.';

  @override
  String get saveSettings => 'Ayarları Kaydet';

  @override
  String get settingsSaved => 'Dil ayarları kaydedildi!';

  @override
  String get errorOccurred => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get hintSystem => 'İpucu Sistemi';

  @override
  String get hintSystemDescription =>
      '💡 İpucu düğmesine basarak kelime kutularında harfleri tek tek açabilirsiniz.';

  @override
  String get hintCost => '• Her ipucunun 2 💎 maliyeti vardır';

  @override
  String get hintReveal => '• Harfler bir kelimeden tamamlanana kadar açılır';

  @override
  String get back => 'Geri Dön';

  @override
  String get play => 'OYNA';

  @override
  String get about => 'HAKKINDA';

  @override
  String get wordChef => 'WORD CHEF';

  @override
  String get findWords => 'Kelimeleri Bul, Zekanı Konuştur!';

  @override
  String get aboutWordChef => 'Word Chef Hakkında';

  @override
  String get aboutWordChefDescription =>
      'Word Chef, harfleri bir çember içinde birleştirerek kelimeler oluşturduğunuz bir kelime bulmaca oyunudur.\n\nHer seviyeyi tamamlamak ve yeni zorlukların kilidini açmak için tüm hedef kelimeleri bulun!\n\nSürüm 1.0.0';

  @override
  String get close => 'Kapat';

  @override
  String get selectLevel => 'Seviye Seçin';

  @override
  String get nextChapter => 'Sonraki Bölüm';

  @override
  String get chapter => 'Bölüm';

  @override
  String chapterWithNumber(Object chapterNumber) {
    return 'Bölüm $chapterNumber';
  }

  @override
  String get beginner => 'Başlangıç';

  @override
  String get elementary => 'Temel';

  @override
  String get intermediate => 'Orta Altı';

  @override
  String get upperIntermediate => 'Orta';

  @override
  String get advanced => 'İleri Altı';

  @override
  String get proficient => 'İleri';

  @override
  String get mixedLevels => 'Karışık Seviyeler';

  @override
  String get english => 'İngilizce';

  @override
  String get german => 'Almanca';

  @override
  String get french => 'Fransızca';

  @override
  String get spanish => 'İspanyolca';

  @override
  String get turkish => 'Türkçe';

  @override
  String get chinese => 'Çince';

  @override
  String get hindi => 'Hintçe';

  @override
  String get audioSettings => 'Ses Ayarları';

  @override
  String get music => 'Müzik';

  @override
  String get soundEffects => 'Ses Efektleri';

  @override
  String get musicVolume => 'Ses Seviyesi';

  @override
  String get realChallengeStarts => 'Asıl Mücadele Başlıyor!';

  @override
  String get congratulationsPracticeOver =>
      'Tebrikler! Artık alıştırmalar bitti. Çeviriler artık otomatik olarak gösterilmeyecek.';

  @override
  String get needTranslationHint => 'Çeviri İpucuna mı İhtiyacınız Var?';

  @override
  String get tapTranslationHintButton =>
      'Çeviri ipucu düğmesine dokunun ve ipucu alın.';

  @override
  String get hereIsTranslation => 'İşte Çeviri!';

  @override
  String get greatWordTranslationAppeared =>
      'Harika! Bir kelimenin çevirisi yukarıda belirdi. Kelimeyi bulmak için bunu kullanın.';

  @override
  String get readyToStart => 'Başlamaya Hazırsın!';

  @override
  String get youSolvedIt =>
      'Bu işi çözdün! Seviyeyi tamamlamak için tüm kelimeleri bulun.';

  @override
  String get startLevel => 'Seviyeye Başla!';

  @override
  String get next => 'Sonraki';

  @override
  String get welcomeToWordChef => 'Word Chef\'e Hoş Geldiniz!';

  @override
  String get learnHowToPlay =>
      'Bu kelime bulmaca oyununu nasıl oynayacağımızı öğrenelim.';

  @override
  String get letterCircle => 'Harf Çemberi';

  @override
  String get useLettersToFormWords =>
      'Kelimeler oluşturmak için bu harfleri kullanın.';

  @override
  String get tryDragging => 'Sürüklemeyi Deneyin!';

  @override
  String get dragFingerBetweenLetters =>
      'Bir kelime oluşturmak için parmağınızı bir harften diğerine sürükleyin. Hadi, deneyin!';

  @override
  String get wordGrid => 'Kelime Izgarası';

  @override
  String get foundWordsAppearHere => 'Bulunan kelimeler burada görünecektir.';

  @override
  String get currentWordDisplay => 'Mevcut Kelime Göstergesi';

  @override
  String get draggedLettersAppearHere =>
      'Sürüklediğiniz harfler burada görünecektir.';

  @override
  String get readyToPlay => 'Oynamaya Hazır!';

  @override
  String get findAllWordsToComplete =>
      'Seviyeyi tamamlamak için tüm kelimeleri bulun. İyi şanslar!';

  @override
  String get startGame => 'Oyuna Başla!';

  @override
  String get error => 'Hata';

  @override
  String get levelFailedToLoad => 'Seviye yüklenemedi';

  @override
  String get alreadyFound => 'Zaten bulundu!';

  @override
  String get bonusWord => 'Bonus kelime! +1 💎';

  @override
  String get great => 'Harika!';

  @override
  String get tryAgain => 'Tekrar deneyin';

  @override
  String youEarnedRubies(int count) {
    return '$count💎 kazandınız!';
  }

  @override
  String get adFailedToLoad =>
      'Reklam yüklenemedi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get hidePreviousHints => 'Önceki ipuçlarını gizle';

  @override
  String get showPreviousHints => 'Önceki ipuçlarını göster';

  @override
  String get revealedTranslationsWillAppear =>
      'Açılan çeviriler burada görünecek';

  @override
  String get findTheseWords => 'Bu kelimeleri bulun:';

  @override
  String get tapForTranslation => 'Çeviri için dokun';

  @override
  String get findTheWord => 'Kelimeyi bul';

  @override
  String get needMoreHints => 'Daha Fazla İpucu mu Lazım?';

  @override
  String get outOfTranslationHints => 'Çeviri ipucunuz kalmadı!';

  @override
  String get chooseOptionToGetMoreHints =>
      'Daha fazla ipucu almak için bir seçenek seçin:';

  @override
  String get watchAdForHints => 'Reklam İzle (+2 ipucu)';

  @override
  String get translationHints => '3 çeviri ipucu';

  @override
  String get unlimitedHintsForHour => '1 saat boyunca sınırsız ipucu';

  @override
  String get cancel => 'İptal';

  @override
  String get adWatchedForHints => 'Reklam izlendi! +2 çeviri ipucu';

  @override
  String get purchasedHints => 'Satın alındı! +3 çeviri ipucu';

  @override
  String get unlimitedTranslationHints =>
      '1 saat boyunca sınırsız çeviri ipucu!';

  @override
  String get outOfLetterHints => 'Harf ipucunuz kalmadı!';

  @override
  String get chooseOptionToGetMoreLetterHints =>
      'Daha fazla harf ipucu almak için bir seçenek seçin:';

  @override
  String get watchAdForLetterHints => 'Reklam İzle (+4 harf ipucu)';

  @override
  String get letterHints => '6 harf ipucu';

  @override
  String get unlimitedLetterHints => '1 saat boyunca sınırsız harf ipucu!';

  @override
  String get adWatchedForLetterHints => 'Reklam izlendi! +4 harf ipucu';

  @override
  String get purchasedLetterHints => 'Satın alındı! +6 harf ipucu';

  @override
  String get letterRevealed => 'Bir harf açıldı!';

  @override
  String get getMoreRubies => 'Daha Fazla Yakut Al';

  @override
  String purchaseNotImplemented(Object amount) {
    return '$amount Yakut için satın alma henüz uygulanmadı.';
  }

  @override
  String get watchAdForRubies => '5 Yakut için Reklam İzle';

  @override
  String get levelCompleted => 'Seviye Tamamlandı';

  @override
  String get congratulations => 'Tebrikler!';

  @override
  String get continueText => 'Devam Et';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get matchWordsInstruction =>
      'Bulduğunuz kelimeleri çevirileriyle eşleştirin.';

  @override
  String get wordsColumn => 'Kelimeler';

  @override
  String get translationsColumn => 'Çeviriler';

  @override
  String get matchSuccess => 'Tüm eşleştirmeler tamamlandı!';

  @override
  String get reviewGame => 'Oyunu Değerlendir';

  @override
  String get reviewGameMessage =>
      'Word Chef oynamayı seviyorsanız, lütfen bir dakikanızı ayırıp oy verin. Desteğiniz için teşekkürler!';

  @override
  String get neverShowAgain => 'Bir Daha Gösterme';

  @override
  String get showLater => 'Daha Sonra Göster';

  @override
  String get reviewNow => 'Şimdi Değerlendir';
}
