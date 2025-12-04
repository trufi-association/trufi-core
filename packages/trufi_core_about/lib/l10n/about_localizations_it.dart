// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AboutLocalizationsIt extends AboutLocalizations {
  AboutLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get aboutCollapseContent =>
      'Trufi Association è una ONG internazionale che promuove un accesso più facile ai trasporti pubblici. Le nostre app aiutano tutti a trovare il modo migliore per spostarsi dal punto A al punto B all\'interno delle loro città.\n\nIn molte città non esistono mappe, percorsi, app o orari ufficiali. Per questo, raccogliamo le informazioni disponibili e, a volte, mappiamo i percorsi da zero lavorando con le persone locali che conoscono bene la città. Un sistema di trasporto facile da usare contribuisce a una maggiore sostenibilità, aria più pulita e una migliore qualità della vita.';

  @override
  String get aboutCollapseContentFoot =>
      'Abbiamo bisogno di mappatori, sviluppatori, pianificatori, tester e molte altre mani.';

  @override
  String get aboutCollapseTitle => 'Maggiori informazioni su Trufi Association';

  @override
  String aboutContent(String appName, String city) {
    return 'Devi andare da qualche parte e non sai quale Trufi o autobus prendere?\nLa $appName lo rende facile!\n\nTrufi Association è un team proveniente dalla Bolivia e da tutto il mondo. Amiamo La Llajta e il trasporto pubblico, ed è per questo che abbiamo sviluppato questa applicazione per renderlo più accessibile. Il nostro obiettivo è fornirti uno strumento pratico che ti permetta di muoverti in sicurezza.\n\nCi impegniamo a migliorare continuamente $appName per fornirti informazioni sempre accurate e utili. Sappiamo che il sistema di trasporto a $city è in continua evoluzione per diverse ragioni, e potrebbe essere possibile che alcuni percorsi non siano del tutto aggiornati.\n\nAffinché $appName sia uno strumento efficace, contiamo sulla tua collaborazione. Se sei a conoscenza di modifiche ad alcune rotte o fermate, ti preghiamo di condividere queste informazioni con noi. Il tuo contributo non solo aiuta a mantenere l\'app aggiornata, ma beneficia anche altri utenti che si affidano a $appName.\n\nGrazie per utilizzare $appName per muoverti a $city. Speriamo che il tempo trascorso con noi ti piaccia!';
  }

  @override
  String get aboutLicenses => 'Licenze';

  @override
  String get aboutOpenSource =>
      'Questa app è rilasciata come Open Source su GitHub. Siamo felici se contribuisci al codice o sviluppi un\'app per la tua città.';

  @override
  String get menuAbout => 'Informazioni';

  @override
  String tagline(String city) {
    return 'Trasporto Pubblico a $city';
  }

  @override
  String get trufiWebsite => 'Sito web di Trufi Association';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get volunteerTrufi => 'Fai volontariato per Trufi';
}
