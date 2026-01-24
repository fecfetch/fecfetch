// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get helloWorld => '你好世界！';

  @override
  String get languageSelection => '语言选择';

  @override
  String get languageSelectionDescription =>
      '请选择您的母语和您想学习的语言。您可以稍后在“设置”菜单中更改这些设置。';

  @override
  String get myNativeLanguage => '我的母语';

  @override
  String get languageIWantToLearn => '我想学习的语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get continueButton => '继续';

  @override
  String get pleaseSelectBothLanguages => '请选择两种语言。';

  @override
  String get languagesMustBeDifferent => '母语和目标语言必须不同。';

  @override
  String get languageSettings => '语言设置';

  @override
  String get nativeLanguage => '母语';

  @override
  String get nativeLanguageDescription => '选择提示语言。';

  @override
  String get targetLanguage => '要学习的语言';

  @override
  String get targetLanguageDescription => '选择您想学习的语言。';

  @override
  String get saveSettings => '保存设置';

  @override
  String get settingsSaved => '语言设置已保存！';

  @override
  String get errorOccurred => '发生错误。请再试一次。';

  @override
  String get settings => '设置';

  @override
  String get hintSystem => '提示系统';

  @override
  String get hintSystemDescription => '💡 您可以按提示按钮逐个显示字词框中的字母。';

  @override
  String get hintCost => '• 每个提示花费 2 💎';

  @override
  String get hintReveal => '• 字母会一直显示，直到一个单词完成';

  @override
  String get back => '返回';

  @override
  String get play => '开始游戏';

  @override
  String get about => '关于';

  @override
  String get wordChef => 'WORD CHEF';

  @override
  String get findWords => '找到单词，挑战你的大脑！';

  @override
  String get aboutWordChef => '关于 Word Chef';

  @override
  String get aboutWordChefDescription =>
      'Word Chef 是一款文字拼图游戏，您可以通过连接圆圈中的字母来组成单词。\n\n找到所有目标单词以完成每个关卡并解锁新挑战！\n\n版本 1.0.0';

  @override
  String get close => '关闭';

  @override
  String get selectLevel => '选择关卡';

  @override
  String get nextChapter => '下一章';

  @override
  String get chapter => '章';

  @override
  String chapterWithNumber(Object chapterNumber) {
    return '第$chapterNumber章';
  }

  @override
  String get beginner => '初学者';

  @override
  String get elementary => '初级';

  @override
  String get intermediate => '中级';

  @override
  String get upperIntermediate => '中高级';

  @override
  String get advanced => '高级';

  @override
  String get proficient => '熟练';

  @override
  String get mixedLevels => '混合关卡';

  @override
  String get english => '英语';

  @override
  String get german => '德语';

  @override
  String get french => '法语';

  @override
  String get spanish => '西班牙语';

  @override
  String get turkish => '土耳其语';

  @override
  String get chinese => '中文';

  @override
  String get hindi => '印地语';

  @override
  String get audioSettings => '音频设置';

  @override
  String get music => '音乐';

  @override
  String get soundEffects => '音效';

  @override
  String get musicVolume => '音量';

  @override
  String get realChallengeStarts => '真正的挑战开始了！';

  @override
  String get congratulationsPracticeOver => '恭喜！练习结束了。翻译将不再自动显示。';

  @override
  String get needTranslationHint => '需要翻译提示吗？';

  @override
  String get tapTranslationHintButton => '点击翻译提示按钮获取提示。';

  @override
  String get hereIsTranslation => '这是翻译！';

  @override
  String get greatWordTranslationAppeared => '太棒了！一个单词的翻译出现在上面。用这个来找单词。';

  @override
  String get readyToStart => '准备开始！';

  @override
  String get youSolvedIt => '你解决了！找到所有单词来完成关卡。';

  @override
  String get startLevel => '开始关卡！';

  @override
  String get next => '下一个';

  @override
  String get welcomeToWordChef => '欢迎来到 Word Chef！';

  @override
  String get learnHowToPlay => '让我们学习如何玩这个文字拼图游戏。';

  @override
  String get letterCircle => '字母圈';

  @override
  String get useLettersToFormWords => '使用这些字母来组成单词。';

  @override
  String get tryDragging => '试试拖拽！';

  @override
  String get dragFingerBetweenLetters => '将手指从一个字母拖到另一个字母来组成单词。来吧，试试看！';

  @override
  String get wordGrid => '单词网格';

  @override
  String get foundWordsAppearHere => '找到的单词将出现在这里。';

  @override
  String get currentWordDisplay => '当前单词显示';

  @override
  String get draggedLettersAppearHere => '您拖拽的字母将出现在这里。';

  @override
  String get readyToPlay => '准备玩游戏！';

  @override
  String get findAllWordsToComplete => '找到所有单词来完成关卡。祝你好运！';

  @override
  String get startGame => '开始游戏！';

  @override
  String get error => '错误';

  @override
  String get levelFailedToLoad => '关卡加载失败';

  @override
  String get alreadyFound => '已经找到了！';

  @override
  String get bonusWord => '奖励单词！+1 💎';

  @override
  String get great => '太棒了！';

  @override
  String get tryAgain => '再试一次';

  @override
  String youEarnedRubies(int count) {
    return '你获得了 $count 颗红宝石！';
  }

  @override
  String get adFailedToLoad => '广告加载失败。请稍后再试。';

  @override
  String get hidePreviousHints => '隐藏之前的提示';

  @override
  String get showPreviousHints => '显示之前的提示';

  @override
  String get revealedTranslationsWillAppear => '显示的翻译将出现在这里';

  @override
  String get findTheseWords => '找到这些单词：';

  @override
  String get tapForTranslation => '点击翻译';

  @override
  String get findTheWord => '找到单词';

  @override
  String get needMoreHints => '需要更多提示吗？';

  @override
  String get outOfTranslationHints => '您的翻译提示用完了！';

  @override
  String get chooseOptionToGetMoreHints => '选择一个选项来获取更多提示：';

  @override
  String get watchAdForHints => '观看广告 (+2 提示)';

  @override
  String get translationHints => '3 翻译提示';

  @override
  String get unlimitedHintsForHour => '1 小时无限提示';

  @override
  String get cancel => '取消';

  @override
  String get adWatchedForHints => '已观看广告！+2 翻译提示';

  @override
  String get purchasedHints => '已购买！+3 翻译提示';

  @override
  String get unlimitedTranslationHints => '1 小时无限翻译提示！';

  @override
  String get outOfLetterHints => '您的字母提示用完了！';

  @override
  String get chooseOptionToGetMoreLetterHints => '选择一个选项来获取更多字母提示：';

  @override
  String get watchAdForLetterHints => '观看广告 (+4 字母提示)';

  @override
  String get letterHints => '6 字母提示';

  @override
  String get unlimitedLetterHints => '1 小时无限字母提示！';

  @override
  String get adWatchedForLetterHints => '已观看广告！+4 字母提示';

  @override
  String get purchasedLetterHints => '已购买！+6 字母提示';

  @override
  String get letterRevealed => '一个字母已被显示！';

  @override
  String get getMoreRubies => '获取更多红宝石';

  @override
  String purchaseNotImplemented(Object amount) {
    return '购买 $amount 红宝石尚未实现。';
  }

  @override
  String get watchAdForRubies => '观看广告获取 5 颗红宝石';

  @override
  String get levelCompleted => '关卡完成';

  @override
  String get congratulations => '恭喜！';

  @override
  String get continueText => '继续';

  @override
  String get notifications => '通知';

  @override
  String get matchWordsInstruction => '将你找到的单词与它们的翻译匹配起来。';

  @override
  String get wordsColumn => '单词';

  @override
  String get translationsColumn => '翻译';

  @override
  String get matchSuccess => '全部匹配完成！';

  @override
  String get reviewGame => '评价游戏';

  @override
  String get reviewGameMessage => '如果您喜欢玩 Word Chef，请花点时间给它评分。感谢您的支持！';

  @override
  String get neverShowAgain => '不再显示';

  @override
  String get showLater => '稍后显示';

  @override
  String get reviewNow => '现在评价';
}
