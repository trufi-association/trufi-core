


import 'trufi_base_localizations.dart';

/// The translations for Portuguese (`pt`).
class TrufiBaseLocalizationPt extends TrufiBaseLocalization {
  TrufiBaseLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get alertLocationServicesDeniedMessage => 'Verifique se o seu dispositivo possui GPS e se as configurações de localização estão ativadas.';

  @override
  String get alertLocationServicesDeniedTitle => 'Nenhuma localização';

  @override
  String get appReviewDialogButtonAccept => 'Escrever análise';

  @override
  String get appReviewDialogButtonDecline => 'Agora Não';

  @override
  String get appReviewDialogContent => 'Ajude-nos com uma revisão na Google Play Store.';

  @override
  String get appReviewDialogTitle => 'Gostando de Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Panoramizar e aplicar zoom ao mapa';

  @override
  String get chooseLocationPageTitle => 'Escolha um ponto';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonDestination => 'Destino';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonError => 'Erro';

  @override
  String get commonFromStation => 'Show on map';

  @override
  String get commonFromStop => 'Show on map';

  @override
  String get commonItineraryNoTransitLegs => 'Show on map';

  @override
  String get commonLeavesAt => 'Leaves';

  @override
  String get commonLoading => 'Show on map';

  @override
  String get commonNoInternet => 'Sem conexão à internet.';

  @override
  String get commonNoResults => 'Sem resultados';

  @override
  String get commonOK => 'Está bem';

  @override
  String get commonOrigin => 'Origem';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonSave => 'Save';

  @override
  String get commonTomorrow => 'Show on map';

  @override
  String get commonUnknownError => 'Erro desconhecido';

  @override
  String get commonUnkownPlace => 'Show on map';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String get commonYourLocation => 'Sua localização';

  @override
  String get errorAmbiguousDestination => 'O planejador de viagem não tem certeza do local para o qual deseja ir. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorAmbiguousOrigin => 'O planejador de viagem não tem certeza do local em que deseja começar. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorAmbiguousOriginDestination => 'Tanto a origem quanto o destino são ambíguos. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorNoBarrierFree => 'A origem e o destino não são acessíveis para cadeiras de rodas';

  @override
  String get errorNoConnectServer => 'No connect with server.';

  @override
  String get errorNoTransitTimes => 'Não há horários de trânsito disponíveis. A data pode ser passada ou muito distante no futuro ou pode não haver serviço de transporte público para a sua viagem na hora que você escolher.';

  @override
  String get errorOutOfBoundary => 'Viagem não é possível. Você pode estar tentando planejar uma viagem fora dos limites dos dados do mapa.';

  @override
  String get errorPathNotFound => 'Viagem não é possível. Seu ponto inicial ou final pode não estar acessível com segurança (por exemplo, você pode estar começando em uma rua residencial conectada apenas a uma rodovia).';

  @override
  String get errorServerCanNotHandleRequest => 'The request has errors that the server is not willing or able to process.';

  @override
  String get errorServerTimeout => 'O planejador de viagem está demorando muito para processar sua solicitação. Por favor, tente novamente mais tarde.';

  @override
  String get errorServerUnavailable => 'Nós lamentamos. O planejador de viagem está temporariamente indisponível. Por favor, tente novamente mais tarde.';

  @override
  String get errorTrivialDistance => 'A origem está a uma distância trivial do destino.';

  @override
  String get errorUnknownDestination => 'O destino é desconhecido. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownOrigin => 'A origem é desconhecida. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownOriginDestination => 'A origem e o destino são desconhecidos. Você pode ser um pouco mais descritivo?';

  @override
  String get followOnFacebook => 'Siga-nos no Facebook';

  @override
  String get followOnInstagram => 'Siga-nos no Instagram';

  @override
  String get followOnTwitter => 'Siga-nos no Twitter';

  @override
  String instructionDistanceKm(Object value) {
    return '$value km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '$value m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '$value min';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min';
  }

  @override
  String get instructionVehicleBike => 'Ônibus';

  @override
  String get instructionVehicleBus => 'Ônibus';

  @override
  String get instructionVehicleCar => 'Carro';

  @override
  String get instructionVehicleCarpool => 'Ônibus';

  @override
  String get instructionVehicleCommuterTrain => 'Ônibus';

  @override
  String get instructionVehicleGondola => 'Gôndola';

  @override
  String get instructionVehicleLightRail => 'Esvaziar';

  @override
  String get instructionVehicleMetro => 'Ônibus';

  @override
  String get instructionVehicleMicro => 'Micro';

  @override
  String get instructionVehicleMinibus => 'Mini onibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleWalk => 'Walk';

  @override
  String get menuConnections => 'Route planner';

  @override
  String get menuSocialMedia => 'Social media';

  @override
  String get menuTransportList => 'Mostrar rotas';

  @override
  String get noRouteError => 'Desculpe, não conseguimos encontrar uma rota. O que você quer fazer?';

  @override
  String get noRouteErrorActionCancel => 'Tente outro destino';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Relatar uma rota ausente';

  @override
  String get noRouteErrorActionShowCarRoute => 'Mostrar percurso de carro';

  @override
  String get readOurBlog => 'Leia nosso blog';

  @override
  String get searchFailLoadingPlan => 'Falha ao carregar o plano.';

  @override
  String get searchHintDestination => 'Escolha o destino';

  @override
  String get searchHintOrigin => 'Escolha o ponto de partida';

  @override
  String get searchPleaseSelectDestination => 'Selecionar destino';

  @override
  String get searchPleaseSelectOrigin => 'Selecionar origem';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Baixe o Trufi App, o aplicativo de transporte público para Cochabamba, em $url';
  }

  @override
  String get themeModeDark => 'Dark Theme';

  @override
  String get themeModeLight => 'Light theme';

  @override
  String get themeModeSystem => 'System Default';
}
