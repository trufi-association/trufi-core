import 'trufi_base_localizations.dart';

/// The translations for Portuguese (`pt`).
class TrufiBaseLocalizationPt extends TrufiBaseLocalization {
  TrufiBaseLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get alertLocationServicesDeniedMessage => 'Certifique-se de que seu dispositivo tenha GPS e que as configurações de localização estejam ativadas.';

  @override
  String get alertLocationServicesDeniedTitle => 'Nenhuma localização';

  @override
  String get appReviewDialogButtonAccept => 'Escrever avaliação';

  @override
  String get appReviewDialogButtonDecline => 'Agora não';

  @override
  String get appReviewDialogContent => 'Apoie-nos com uma análise na Loja do Google Play.';

  @override
  String get appReviewDialogTitle => 'Gostando da Trufi?';

  @override
  String get chooseLocationPageSubtitle => 'Amplia e move o mapa para centralizar o marcador';

  @override
  String get chooseLocationPageTitle => 'Escolha um ponto no mapa';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirmLocation => 'Confirmar localização';

  @override
  String get commonDestination => 'Endereço de destino';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonError => 'Erro';

  @override
  String get commonFromStation => 'Da estação';

  @override
  String get commonFromStop => 'Da parada';

  @override
  String get commonItineraryNoTransitLegs => 'Saia quando for melhor para você';

  @override
  String get commonLeavesAt => 'Sair';

  @override
  String get commonLoading => 'Carregando...';

  @override
  String get commonNoInternet => 'Sem conexão de internet';

  @override
  String get commonNoResults => 'Sem resultados';

  @override
  String get commonOK => 'OK';

  @override
  String get commonOrigin => 'Origem';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonTomorrow => 'Amanhã';

  @override
  String get commonUnknownError => 'Erro desconhecido';

  @override
  String get commonUnkownPlace => 'Local desconhecido';

  @override
  String get commonWait => 'Aguarde';

  @override
  String get commonWalk => 'Caminhe';

  @override
  String get commonYourLocation => 'Sua localização';

  @override
  String get errorAmbiguousDestination => 'O planejador de viagens não tem certeza do local para o qual deseja ir. Selecione uma das opções a seguir ou seja mais específico.';

  @override
  String get errorAmbiguousOrigin => 'O planejador de viagens não tem certeza do local de onde você deseja começar sua viagem. Selecione uma das opções a seguir ou seja mais específico.';

  @override
  String get errorAmbiguousOriginDestination => 'Tanto a origem quanto o destino são ambíguos. Selecione entre as seguintes opções ou seja mais específico.';

  @override
  String get errorNoBarrierFree => 'Tanto a origem quanto o destino não são acessíveis para pessoa em cadeira de rodas.';

  @override
  String get errorNoConnectServer => 'Sem conexão com o servidor.';

  @override
  String get errorNoTransitTimes => 'Não há horários de trânsito disponíveis. A data pode ser anterior à atual ou muito longe no futuro ou pode não haver serviço de trânsito para sua viagem no momento escolhido.';

  @override
  String get errorOutOfBoundary => 'Essa viagem não é possível. Você pode estar tentando planejar uma viagem fora do limite de dados do mapa.';

  @override
  String get errorPathNotFound => 'Essa viagem não é possível. Seu ponto de partida ou de chegada pode não ser acessível com segurança (por exemplo, você pode estar partindo de uma rua residencial conectada apenas a uma rodovia).';

  @override
  String get errorServerCanNotHandleRequest => 'A solicitação tem erros que o servidor não pode ou não foi capaz de processar.';

  @override
  String get errorServerTimeout => 'O planejador de viagens está demorando muito para processar sua solicitação. Por favor, tente novamente mais tarde.';

  @override
  String get errorServerUnavailable => 'Sentimos muito. O planeador de viagens está temporariamente indisponível. Por favor, tente novamente mais tarde.';

  @override
  String get errorTrivialDistance => 'Origem é desconhecida. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownDestination => 'O destino é desconhecido. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownOrigin => 'A origem é desconhecida. Você pode ser um pouco mais descritivo?';

  @override
  String get errorUnknownOriginDestination => 'Tanto a origem quanto o destino são desconhecidos. Você pode ser um pouco mais descritivo?';

  @override
  String followOnSocialMedia(Object value) {
    return 'Siga-nos no $value';
  }

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
    return '$value h';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '$value min';
  }

  @override
  String get instructionVehicleBike => 'Bicicleta';

  @override
  String get instructionVehicleBus => 'Ônibus';

  @override
  String get instructionVehicleCar => 'Carro';

  @override
  String get instructionVehicleCarpool => 'Carona';

  @override
  String get instructionVehicleCommuterTrain => 'Trem suburbano';

  @override
  String get instructionVehicleGondola => 'Gôndola';

  @override
  String get instructionVehicleLightRail => '(VLT) Veículo Leve sobre trilhos';

  @override
  String get instructionVehicleMetro => 'Metrô';

  @override
  String get instructionVehicleMicro => 'Micro ônibus';

  @override
  String get instructionVehicleMinibus => 'Minibus';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String get instructionVehicleWalk => 'A pé';

  @override
  String get menuConnections => 'Planejador de rotas';

  @override
  String get menuSocialMedia => 'Mídia social';

  @override
  String get menuTransportList => 'Mostrar rotas';

  @override
  String get noRouteError => 'Desculpe, não conseguimos encontrar uma rota. O que você quer fazer?';

  @override
  String get noRouteErrorActionCancel => 'Tente outro destino';

  @override
  String get noRouteErrorActionReportMissingRoute => 'Relatar uma rota ausente';

  @override
  String get noRouteErrorActionShowCarRoute => 'Mostrar rota de carro';

  @override
  String get notShowAgain => 'Não mostre novamente';

  @override
  String get readOurBlog => 'Leia nosso blog';

  @override
  String get searchFailLoadingPlan => 'Falha ao carregar o plano';

  @override
  String get searchHintDestination => 'Escolha o destino';

  @override
  String get searchHintOrigin => 'Escolha a origem';

  @override
  String get searchPleaseSelectDestination => 'Selecione o destino';

  @override
  String get searchPleaseSelectOrigin => 'Selecione a origem';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Baixe $appTitle, o aplicativo de transporte público para $cityName, em $url';
  }

  @override
  String get commonShowMap => 'Show on map';

  @override
  String get commonMapSettings => 'Map Settings';

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get selectYourPointInterest => 'Pontos de Interesse';

  @override
  String get themeModeDark => 'Tema escuro';

  @override
  String get themeModeLight => 'Tema claro';

  @override
  String get themeModeSystem => 'Sistema padrão';
}
