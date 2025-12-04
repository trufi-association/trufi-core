// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'about_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AboutLocalizationsPt extends AboutLocalizations {
  AboutLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutCollapseContent =>
      'A Trufi Association é uma ONG internacional que promove um acesso mais fácil ao transporte público. Nossos aplicativos ajudam todos a encontrar a melhor maneira de ir do ponto A ao ponto B em suas cidades.\n\nEm muitas cidades não há mapas oficiais, rotas, aplicativos ou horários. Então compilamos as informações disponíveis e, às vezes, até mapeamos rotas do zero trabalhando com pessoas locais que conhecem a cidade. Um sistema de transporte fácil de usar contribui para maior sustentabilidade, ar mais limpo e melhor qualidade de vida.';

  @override
  String get aboutCollapseContentFoot =>
      'Precisamos de mapeadores, desenvolvedores, planejadores, testadores e muitas outras mãos.';

  @override
  String get aboutCollapseTitle => 'Mais sobre a Trufi Association';

  @override
  String aboutContent(String appName, String city) {
    return 'Precisa ir a algum lugar e não sabe qual Trufi ou ônibus pegar?\nO $appName facilita!\n\nA Trufi Association é uma equipe da Bolívia e de todo o mundo. Amamos La Llajta e o transporte público, por isso desenvolvemos este aplicativo para tornar o transporte público mais acessível. Nosso objetivo é fornecer uma ferramenta prática que permita que você se mova com segurança.\n\nNos esforçamos para melhorar constantemente o $appName para sempre fornecer informações precisas e úteis. Sabemos que o sistema de transporte em $city está em constante mudança por vários motivos, então é possível que algumas rotas não estejam completamente atualizadas.\n\nPara tornar o $appName uma ferramenta eficaz, contamos com sua colaboração. Se você souber de mudanças em algumas rotas ou paradas, pedimos que compartilhe essas informações conosco. Sua contribuição não apenas ajuda a manter o aplicativo atualizado, mas também beneficia outros usuários que dependem do $appName.\n\nObrigado por usar o $appName para se locomover em $city. Esperamos que você aproveite seu tempo conosco!';
  }

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutOpenSource =>
      'Este aplicativo é lançado como código aberto no GitHub. Damos as boas-vindas a contribuições ao código ou ao desenvolvimento de um aplicativo para sua própria cidade.';

  @override
  String get menuAbout => 'Sobre nós';

  @override
  String tagline(String city) {
    return 'Transporte público em $city';
  }

  @override
  String get trufiWebsite => 'Site da Trufi Association';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get volunteerTrufi => 'Seja voluntário para Trufi';
}
