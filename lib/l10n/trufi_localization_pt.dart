
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'trufi_localization.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Portuguese (`pt`).
class TrufiLocalizationPt extends TrufiLocalization {
  TrufiLocalizationPt([String locale = 'pt']) : super(locale);

  @override
  String get aboutContent => 'Somos uma equipe boliviana e internacional de pessoas que amam e apoiam o transporte público.\n\nNós desenvolvemos este aplicativo para facilitar o uso do sistema de transporte em Cochabamba e arredores.';

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutOpenSource => 'Este aplicativo é lançado como código aberto no GitHub. Sinta-se livre para contribuir ou trazê-lo para sua própria cidade.';

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
  String get bikeRentalBikeStation => 'Bike station';

  @override
  String get bikeRentalFetchRentalBike => 'Fetch a rental bike:';

  @override
  String get bikeRentalNetworkFreeFloating => 'Destination is not a designated drop-off area. Rental cannot be completed here. Please check terms & conditions for additional fees.';

  @override
  String get carParkCloseCapacityMessage => 'This car park is close to capacity. Please allow additional time for you journey.';

  @override
  String get carParkExcludeFull => 'Exclude full car parks';

  @override
  String get chooseLocationPageSubtitle => 'Panoramizar e aplicar zoom ao mapa';

  @override
  String get chooseLocationPageTitle => 'Escolha um ponto';

  @override
  String get commonArrival => 'Arrival';

  @override
  String get commonBikesAvailable => 'Show on map';

  @override
  String get commonCall => 'Show on map';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonCitybikes => 'Citybikes';

  @override
  String get commonConfirmLocation => 'Show on map';

  @override
  String get commonCustomPlaces => 'Custom places';

  @override
  String get commonDeparture => 'Departure';

  @override
  String get commonDestination => 'Destino';

  @override
  String get commonDetails => 'Walk';

  @override
  String get commonError => 'Erro';

  @override
  String get commonFailLoading => 'Falha ao carregar dados';

  @override
  String get commonFavoritePlaces => 'Favorite places';

  @override
  String get commonFromStation => 'Show on map';

  @override
  String get commonFromStop => 'Show on map';

  @override
  String get commonGoOffline => 'Fique offline';

  @override
  String get commonGoOnline => 'Fique online';

  @override
  String get commonItineraryNoTransitLegs => 'Show on map';

  @override
  String get commonLeavesAt => 'Show on map';

  @override
  String get commonLeavingNow => 'Leaving now';

  @override
  String get commonLoading => 'Show on map';

  @override
  String get commonMapSettings => 'Show on map';

  @override
  String get commonMoreInformartion => 'Show on map';

  @override
  String get commonNoInternet => 'Sem conexão à internet.';

  @override
  String get commonNow => 'Show on map';

  @override
  String get commonOK => 'Está bem';

  @override
  String get commonOnDemandTaxi => 'Show on map';

  @override
  String get commonOrigin => 'Origem';

  @override
  String get commonPlatform => 'Show on map';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonShowMap => 'Show on map';

  @override
  String get commonTomorrow => 'Show on map';

  @override
  String get commonTrack => 'Show on map';

  @override
  String get commonUnknownError => 'Erro desconhecido';

  @override
  String get commonUnkownPlace => 'Show on map';

  @override
  String get commonWait => 'Wait';

  @override
  String get commonWalk => 'Walk';

  @override
  String get copyrightsPriceProvider => 'Fare information provided by Nahverkehrsgesellschaft Baden-Württemberg mbH (NVBW). No liability for the correctness of the information.';

  @override
  String defaultLocationAdd(Object defaultLocation) {
    return 'Versão {version}';
  }

  @override
  String get defaultLocationHome => 'Home';

  @override
  String get defaultLocationWork => 'Work';

  @override
  String departureBikeStation(Object departureStop, Object departureTime) {
    return 'Rotas: {routeContributors} e todos os usuários que fizeram upload de rotas para o OpenStreetMap, {osmContributors}.\nEntre em contato conosco se você quiser participar da comunidade OpenStreetMap!';
  }

  @override
  String description(Object cityName) {
    return 'A melhor maneira de viajar com trufis, micros e ônibus por Cochabamba.';
  }

  @override
  String get donate => 'Doar';

  @override
  String get errorAmbiguousDestination => 'O planejador de viagem não tem certeza do local para o qual deseja ir. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorAmbiguousOrigin => 'O planejador de viagem não tem certeza do local em que deseja começar. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorAmbiguousOriginDestination => 'Tanto a origem quanto o destino são ambíguos. Selecione uma das seguintes opções ou seja mais específico.';

  @override
  String get errorCancelledByUser => 'Canceled by user';

  @override
  String get errorEmailFeedback => 'Could not open mail feedback app, the URL or email is incorrect';

  @override
  String get errorNoBarrierFree => 'A origem e o destino não são acessíveis para cadeiras de rodas';

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
  String get feedbackContent => 'Você tem sugestões para o nosso aplicativo ou encontrou alguns erros nos dados?\n Gostaríamos muito de ouvir de você!\nCertifique-se de adicionar seu endereço de e-mail ou telefone, para que possamos responder a você.';

  @override
  String get feedbackTitle => 'Envie-nos um e-mail';

  @override
  String get fetchMoreItinerariesEarlierDepartures => 'Earlier departures';

  @override
  String get fetchMoreItinerariesLaterDeparturesTitle => 'Later departures';

  @override
  String get followOnFacebook => 'Siga-nos no Facebook';

  @override
  String get followOnInstagram => 'Siga-nos no Instagram';

  @override
  String get followOnTwitter => 'Siga-nos no Twitter';

  @override
  String get infoMessageDestinationOutsideService => 'No route suggestions were found because the destination is outside the service area.';

  @override
  String get infoMessageNoRouteMsg => 'Unfortunately, no route suggestions were found.';

  @override
  String get infoMessageNoRouteMsgWithChanges => 'Unfortunately, no route suggestions were found. Please check your search settings or try changing the origin or destination.';

  @override
  String get infoMessageNoRouteOriginNearDestination => 'No route suggestions were found because the origin and destination are the same.';

  @override
  String get infoMessageNoRouteOriginSameAsDestination => 'No route suggestions were found because the origin and destination are very close to each other.';

  @override
  String get infoMessageNoRouteShowingAlternativeOptions => 'No route suggestions were found with the your settings. However, we found the following route options:';

  @override
  String get infoMessageOnlyCyclingRoutes => 'Your search returned only cycling routes.';

  @override
  String get infoMessageOnlyWalkingCyclingRoutes => 'Your search returned only walking and cycling routes.';

  @override
  String get infoMessageOnlyWalkingRoutes => 'Your search returned only walking routes.';

  @override
  String get infoMessageOriginOutsideService => 'No route suggestions were found because the origin is outside the service area.';

  @override
  String get infoMessageUseNationalServicePrefix => 'We recommend you try the national journey planner,';

  @override
  String instructionDistanceKm(Object value) {
    return '${value} km';
  }

  @override
  String instructionDistanceMeters(Object value) {
    return '${value} m';
  }

  @override
  String instructionDurationHours(Object value) {
    return '${value} min';
  }

  @override
  String instructionDurationMinutes(Object value) {
    return '${value} min';
  }

  @override
  String instructionJunction(Object street1, Object street2) {
    return 'Esvaziar';
  }

  @override
  String instructionRide(Object vehicle, Object distance, Object duration, Object location) {
    return 'Ride ${vehicle} for ${duration} (${distance}) to\n${location}';
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
  String get instructionVehicleOnCar => 'Carro';

  @override
  String get instructionVehicleSharing => 'Ônibus';

  @override
  String get instructionVehicleSharingCarSharing => 'Ônibus';

  @override
  String get instructionVehicleSharingRegioRad => 'Ônibus';

  @override
  String get instructionVehicleSharingTaxi => 'Ônibus';

  @override
  String get instructionVehicleTaxi => 'Carro';

  @override
  String get instructionVehicleTrufi => 'Trufi';

  @override
  String instructionWalk(Object distance, Object duration, Object location) {
    return 'Walk ${duration} (${distance}) to\n${location}';
  }

  @override
  String get itineraryBuyTicket => 'Buy tickets';

  @override
  String get itineraryMissingPrice => 'No price information';

  @override
  String get itineraryPriceOnlyPublicTransport => 'Price only valid for public transport part of the journey.';

  @override
  String get itinerarySummaryBikeAndPublicRailSubwayTitle => 'Take your bike with you on the train or to metro';

  @override
  String get itinerarySummaryBikeParkTitle => 'Leave your bike at a Park & Ride';

  @override
  String get itineraryTicketsTitle => 'Required tickets';

  @override
  String get itineraryTicketTitle => 'Required ticket';

  @override
  String get mapTypeLabel => 'Map Type';

  @override
  String get mapTypeSatelliteCaption => 'Satellite';

  @override
  String get mapTypeStreetsCaption => 'Streets';

  @override
  String get mapTypeTerrainCaption => 'Terrain';

  @override
  String get menuAbout => 'Sobre';

  @override
  String get menuAppReview => 'Avalie o aplicativo';

  @override
  String get menuConnections => 'Mostrar rotas';

    @override
  String get listofBusses => 'Lista de ônibus';

  @override
  String get menuFeedback => 'Enviar comentários.';

  @override
  String get menuOnline => 'Conectadas';

  @override
  String get menuShareApp => 'Compartilhe o aplicativo';

  @override
  String get menuTeam => 'Equipe';

  @override
  String get menuYourPlaces => 'Your places';

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
  String get savedPlacesEnterNameTitle => 'Enter name';

  @override
  String get savedPlacesRemoveLabel => 'Remove place';

  @override
  String get savedPlacesSelectIconTitle => 'Select symbol';

  @override
  String get savedPlacesSetIconLabel => 'Change symbol';

  @override
  String get savedPlacesSetNameLabel => 'Edit name';

  @override
  String get savedPlacesSetPositionLabel => 'Edit position';

  @override
  String get searchFailLoadingPlan => 'Falha ao carregar o plano.';

  @override
  String get searchHintDestination => 'Escolha o destino';

  @override
  String get searchHintOrigin => 'Escolha o ponto de partida';

  @override
  String get searchItemChooseOnMap => 'Escolha no mapa';

  @override
  String get searchItemNoResults => 'Sem resultados';

  @override
  String get searchItemYourLocation => 'Sua localização';

  @override
  String get searchMapMarker => 'Marcador de mapa';

  @override
  String get searchPleaseSelectDestination => 'Selecionar destino';

  @override
  String get searchPleaseSelectOrigin => 'Selecionar origem';

  @override
  String get searchTitleFavorites => 'Favoritas';

  @override
  String get searchTitlePlaces => 'Locais';

  @override
  String get searchTitleRecent => 'Recente';

  @override
  String get searchTitleResults => 'Procurar Resultados';

  @override
  String get settingPanelAccessibility => 'Accessibility';

  @override
  String get settingPanelAvoidTransfers => 'Avoid transfers';

  @override
  String get settingPanelAvoidWalking => 'Avoid walking';

  @override
  String get settingPanelBikingSpeed => 'Biking speed';

  @override
  String get settingPanelMyModesTransport => 'My modes of transport';

  @override
  String get settingPanelMyModesTransportBike => 'Bike';

  @override
  String get settingPanelMyModesTransportBikeRide => 'Park and Ride';

  @override
  String get settingPanelMyModesTransportParkRide => 'Park and Ride';

  @override
  String get settingPanelTransportModes => 'Transport modes';

  @override
  String get settingPanelWalkingSpeed => 'Walking speed';

  @override
  String get settingPanelWheelchair => 'Wheelchair';

  @override
  String shareAppText(Object url, Object appTitle, Object cityName) {
    return 'Baixe o Trufi App, o aplicativo de transporte público para Cochabamba, em ${url}';
  }

  @override
  String tagline(Object city) {
    return 'Transporte público em Cochabamba';
  }

  @override
  String get teamContent => 'Somos uma equipe internacional chamada Associação Trufi que criou este aplicativo com a ajuda de muitos voluntários! Deseja melhorar o aplicativo Trufi e fazer parte de nossa equipe? Entre em contato conosco:';

  @override
  String teamSectionRepresentatives(Object representatives) {
    return 'Representantes: ${representatives}';
  }

  @override
  String teamSectionRoutes(Object osmContributors, Object routeContributors) {
    return 'Rotas: ${routeContributors} e todos os usuários que fizeram upload de rotas para o OpenStreetMap, ${osmContributors}.\nEntre em contato conosco se você quiser participar da comunidade OpenStreetMap!';
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
  String get title => 'Trufi App';

  @override
  String get typeSpeedAverage => 'Average';

  @override
  String get typeSpeedCalm => 'Calm';

  @override
  String get typeSpeedFast => 'Fast';

  @override
  String get typeSpeedPrompt => 'Prompt';

  @override
  String get typeSpeedSlow => 'Slow';

  @override
  String version(Object version) {
    return 'Versão ${version}';
  }
}
