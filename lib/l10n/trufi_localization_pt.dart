
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Portuguese (`pt`).
class TrufiLocalizationPt extends TrufiLocalization {
  TrufiLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get title => 'Trufi App';

  @override
  String tagline(Object city) {
    return 'Transporte público em Cochabamba';
  }

  @override
  String description(Object cityName) {
    return 'A melhor maneira de viajar com trufis, micros e ônibus por Cochabamba.';
  }

  @override
  String version(Object version) {
    return 'Versão ${version}';
  }

  @override
  String get alertLocationServicesDeniedTitle => 'Nenhuma localização';

  @override
  String get alertLocationServicesDeniedMessage => 'Verifique se o seu dispositivo possui GPS e se as configurações de localização estão ativadas.';

  @override
  String get commonOK => 'Está bem';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonGoOffline => 'Fique offline';

  @override
  String get commonGoOnline => 'Fique online';

  @override
  String get commonDestination => 'Destino';

  @override
  String get commonOrigin => 'Origem';

  @override
  String get commonNoInternet => 'Sem conexão à internet.';

  @override
  String get commonFailLoading => 'Falha ao carregar dados';

  @override
  String get commonUnknownError => 'Erro desconhecido';

  @override
  String get commonError => 'Erro';

  @override
  String get noRouteError => 'Desculpe, não conseguimos encontrar uma rota. O que você quer fazer?';

  @override
  String get noRouteErrorActionCancel => 'Tente outro destino';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Relatar uma rota ausente';

  @override
  String get noRouteErrorActionShowCarRoute => 'Mostrar percurso de carro';

  @override
  String get errorServerUnavailable => 'Nós lamentamos. O planejador de viagem está temporariamente indisponível. Por favor, tente novamente mais tarde.';

  @override
  String get errorOutOfBoundary => 'Viagem não é possível. Você pode estar tentando planejar uma viagem fora dos limites dos dados do mapa.';

  @override
  String get errorPathNotFound => 'Viagem não é possível. Seu ponto inicial ou final pode não estar acessível com segurança (por exemplo, você pode estar começando em uma rua residencial conectada apenas a uma rodovia).';

  @override
  String get errorNoTransitTimes => 'Não há horários de trânsito disponíveis. A data pode ser passada ou muito distante no futuro ou pode não haver serviço de transporte público para a sua viagem na hora que você escolher.';

  @override
  String get errorServerTimeout => 'O planejador de viagem está demorando muito para processar sua solicitação. Por favor, tente novamente mais tarde.';

  @override
  String get errorTrivialDistance => 'A origem está a uma distância trivial do destino.';

  @override
  String get errorServerCanNotHandleRequest => '';

  @override
  String get errorUnknownOrigin => 'A origem é desconhecida. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownDestination => 'O destino é desconhecido. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownOriginDestination => 'A origem e o destino são desconhecidos. Você pode ser um pouco mais descritivo?';

  @override
  String get errorNoBarrierFree => 'A origem e o destino não são acessíveis para cadeiras de rodas';

  @override
  String get errorAmbiguousOrigin => 'O planejador de viagem não tem certeza do local em que deseja começar. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorAmbiguousDestination => 'O planejador de viagem não tem certeza do local para o qual deseja ir. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorAmbiguousOriginDestination => 'Tanto a origem quanto o destino são ambíguos. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get searchHintOrigin => 'Escolha o ponto de partida';

  @override
  String get searchHintDestination => 'Escolha o destino';

  @override
  String get searchItemChooseOnMap => 'Escolha no mapa';

  @override
  String get searchItemYourLocation => 'Sua localização';

  @override
  String get searchItemNoResults => 'Sem resultados';

  @override
  String get searchTitlePlaces => 'Locais';

  @override
  String get searchTitleRecent => 'Recente';

  @override
  String get searchTitleFavorites => 'Favoritas';

  @override
  String get searchTitleResults => 'Procurar Resultados';

  @override
  String get searchPleaseSelectOrigin => 'Selecionar origem';

  @override
  String get searchPleaseSelectDestination => 'Selecionar destino';

  @override
  String get searchFailLoadingPlan => 'Falha ao carregar o plano.';

  @override
  String get searchMapMarker => 'Marcador de mapa';

  @override
  String get chooseLocationPageTitle => 'Escolha um ponto';

  @override
  String get chooseLocationPageSubtitle => 'Panoramizar e aplicar zoom ao mapa';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return '';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return '';
  }

  @override
  String get instructionVehicleBus => 'Ônibus';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Mini onibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleCar => 'Carro';

  @override
  String get instructionVehicleGondola => 'Gôndola';

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min';
  }

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m';
  }

  @override
  String get menuConnections => 'Mostrar rotas';

  @override
  String get menuAbout => 'Sobre';

  @override
  String get menuTeam => 'Equipe';

  @override
  String get menuFeedback => 'Enviar comentários.';

  @override
  String get menuOnline => 'Conectadas';

  @override
  String get menuAppReview => 'Avalie o aplicativo';

  @override
  String get menuShareApp => 'Compartilhe o aplicativo';

  @override
  String shareAppText(Object url) {
    return 'Baixe o Trufi App, o aplicativo de transporte público para Cochabamba, em ${url}';
  }

  @override
  String get feedbackContent => 'Você tem sugestões para o nosso aplicativo ou encontrou alguns erros nos dados?\n Gostaríamos muito de ouvir de você!\nCertifique-se de adicionar seu endereço de e-mail ou telefone, para que possamos responder a você.';

  @override
  String get feedbackTitle => 'Envie-nos um e-mail';

  @override
  String get aboutContent => 'Somos uma equipe boliviana e internacional de pessoas que amam e apoiam o transporte público.\n\nNós desenvolvemos este aplicativo para facilitar o uso do sistema de transporte em Cochabamba e arredores.';

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutOpenSource => 'Este aplicativo é lançado como código aberto no GitHub. Sinta-se livre para contribuir ou trazê-lo para sua própria cidade.';

  @override
  String get teamContent => 'Somos uma equipe internacional chamada Associação Trufi que criou este aplicativo com a ajuda de muitos voluntários! Deseja melhorar o aplicativo Trufi e fazer parte de nossa equipe? Entre em contato conosco:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Representantes: ${representatives}';
  }

  @override
  String teamSectionTeam(Object teamMembers) {
    return 'Equipe: ${teamMembers}';
  }

  @override
  String teamSectionTranslations(Object translators) {
    return 'Traduções: ${translators}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Rotas: ${routeContributors} e todos os usuários que fizeram upload de rotas para o OpenStreetMap, ${osmContributors}.\nEntre em contato conosco se você quiser participar da comunidade OpenStreetMap!';
  }

  @override
  String get donate => 'Doar';

  @override
  String get readOurBlog => 'Leia nosso blog';

  @override
  String get followOnFacebook => 'Siga-nos no Facebook';

  @override
  String get followOnTwitter => 'Siga-nos no Twitter';

  @override
  String get followOnInstagram => 'Siga-nos no Instagram';

  @override
  String get appReviewDialogTitle => 'Gostando de Trufi?';

  @override
  String get appReviewDialogContent => 'Ajude-nos com uma revisão na Google Play Store.';

  @override
  String get appReviewDialogButtonDecline => 'Agora Não';

  @override
  String get appReviewDialogButtonAccept => 'Escrever análise';

  @override
  String instructionJunction(Object street1, Object street2) {
    return 'Esvaziar';
  }

  @override
  String get instructionVehicleLightRail => 'Esvaziar';

  @override
  String get menuYourPlaces => '';
}
