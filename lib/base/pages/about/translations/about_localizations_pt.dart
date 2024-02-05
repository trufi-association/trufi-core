import 'about_localizations.dart';

/// The translations for Portuguese (`pt`).
class AboutLocalizationPt extends AboutLocalization {
  AboutLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutCollapseContent => 'A Trufi Association é uma ONG internacional que promove acesso mais fácil ao transporte público. Nossos aplicativos ajudam as pessoas a encontrar a melhor maneira de ir do ponto A ao ponto B dentro de suas cidades.\n\nEm muitas cidades não há mapas, rotas, aplicativos ou horários oficiais. Por isso, compilamos as informações disponíveis e, às vezes, também mapeamos rotas do zero, trabalhando com pessoas locais que conhecem a cidade. Um sistema de transporte fácil de usar contribui para maior sustentabilidade, ar mais limpo e melhor qualidade de vida.';

  @override
  String get aboutCollapseContentFoot => 'Torne-se parte dos nosso time de voluntários! Nós precisamos de pessoas para fazer o mapeamento, de desenvolvedores, de planejadores, pessoas que nos ajudem a fazer testes e outras muitas mãos!';

  @override
  String get aboutCollapseTitle => 'Mais sobre a Trufi Association';

  @override
  String aboutContent(Object appName, Object city) {
    return 'Precisa ir a algum lugar e não sabe qual trufi ou ônibus pegar?\nO aplicativo Trufi facilita isso!\nA Trufi Association é uma equipe da Bolívia e de outros países. Adoramos La Llajta e o transporte público, por isso desenvolvemos este aplicativo para facilitar o transporte. Nosso objetivo é fornecer uma ferramenta prática que lhe permita navegar com confiança.\nEstamos comprometidos com a melhoria contínua do $appName para oferecer a você informações cada vez mais precisas e úteis. Sabemos que o sistema de transporte em $city passa por mudanças devido a diferentes motivos, portanto, é possível que algumas rotas não estejam completamente atualizadas.\nPara tornar o $appName uma ferramenta eficaz, contamos com a colaboração de nossos usuários. Se tiver conhecimento de alterações em algumas rotas ou paradas, recomendamos que compartilhe essas informações conosco. Sua contribuição não apenas ajudará a manter o aplicativo atualizado, mas também beneficiará outros usuários que dependem do $appName.\nObrigado por escolher o $appName para se locomover em $city, esperamos que aproveite sua experiência conosco!';
  }

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutOpenSource => 'Este aplicativo é lançado como código aberto no GitHub. Sinta-se à vontade para contribuir com o código ou trazer um aplicativo para sua própria cidade.';

  @override
  String get menuAbout => 'Sobre Nós';

  @override
  String tagline(Object city) {
    return 'Transporte público em $city';
  }

  @override
  String get trufiWebsite => 'Website da Trufi Association';

  @override
  String version(Object version) {
    return 'Versão $version';
  }

  @override
  String get volunteerTrufi => 'Torne-se um voluntário da Trufi';
}
