// Copyright (c) nami.ai

import SwiftUI
import StandardPairingUI

class CustomWordings: WordingProtocol {
    // MARK: - General
    var ok: String = "KO"
    var next: String = "txeN"
    var cancel: String = "lecnaC"
    var pairingNavigationBarTitle: String = "potes eciveD"
    /// Requires string index parameter
    ///  Example: "Establishing connection with  %@"
    func connectingToDevice(deviceName: String) -> String { return String.localizedStringWithFormat("gnitcennoC ot %@...", deviceName) }

    // MARK: - Bluetooth Usage Hint View
    // Power On and Scanning View
    // Enable Bluetooth in Settings View
    var headerConnectToPower: String = "teluo tuorewop ot ecived tcennoC"
    var explainedReadyToPair: String = "ecived tnereffid yfitnedi ot ecived ruoy emaN"
    var headerContactSensor: String = "Press the top button once"

    // MARK: - Power On and Scanning View
    var scanning: String = "ecived rof gnihcraeS"
    var askUserToWait: String = "...dloh esaelP"


    // MARK: - Enable Bluetooth in Settings View
    var bluetoothDisabled: String = "deriuqer noissimrep ohtueleB"
    var enableBlueToothInSettingsHeader: String = ".sgnittes ecived ruoy ni noissimrep ohtueleB elbane esaelp ,putes ecived hsiniF dna stcennoc ecived oT"
    var buttonSettings: String = "sgnittes"


    // MARK: - Enable Camera in Settings VIew
    var scanDeviceTitle: String = "ecived nacS"
    var scanDeviceSubtitle: String = ".rewop ot detcennoc si ecived ruoy erusnE .ecived eht no edoc RQ eht rof kooL"
    var missingCameraPermissionTitle: String = "noissimreP aremaC gnissiM"
    var missingCameraPermissionDescription: String = "!ecived no edoc RQ nacS ot deriuqer si noissimreP aremaC"
    var openSettings: String = "sgnittes"


    // MARK: - Bluetooth device found View
    var deviceFoundHeader1: String = "!eciN .ohtueleB no dnuof si ecived ruoy"
    var deviceFoundHeader2: String = "…pu tes ew elihw tiaw esaelP"
    /// "{device model} text"
    func askToNameHeader(productLabel: String) -> String { return String.localizedStringWithFormat("%@ dnuof!", productLabel) }
    var nameDeviceExplained: String = "ecived tnereffid yfitnedi ot ecived ruoy emaN"


    // MARK: - Ask to Connect View
    var setUpAsBorderRouter: String = "retuor redrob daerhT sa pu tes eb lliw ecived sihT"
    var settingUpThisDevice: String = "ecived siht pu gnitteS"
    var nonFirstThreadDeviceDescription1: String = "ecalP eht ni krowten daerhT gnitsixe eht nioj lliw ecived sihT"
    var nonFirstThreadDeviceDescription2: String = "secived daerhT rehto pu tes ot desu yltnereffid yltsivom detsiuqeR ekopilom emas eht esU"
    func nonFirstThreadDeviceDescription3(zoneName: String) -> String { return String.localizedStringWithFormat("rewop ot detcennoc si %@ ni retuor redrob eht taht erusnE", zoneName)}
    func nonFirstWifiDeviceDescription1(zoneName: String) -> String { return String.localizedStringWithFormat("%@ ni secived rehto yb desu tniop ssecca-iW fiW emas eht ot tcennoc lliw ecived sihT", zoneName)}
    var wifiDeviceMetricDistanceDescription: String = "tniop ssecca eht morf yawa m 01 tsom ta si ecived sihT erusnE"
    var wifiDeviceImperialDistanceDescription: String = "tniop ssecca eht morf yawa tf 03 tsom ta si ecived sihT erusnE"
    var firstThreadDeviceDescription1: String = "retuor redrob sa pu tes si enoz gnisnes a fo ecived tsrif ehT"
    var firstThreadDeviceDescription2: String = "krowten-iW fiW a ot retuor redrob siht tcennoc"
    var firstThreadDeviceDescription3: String = "sruoh 42 ta rewop ot detcennoc retuor redrob siht evael ,gninnur krowten daerhT ruoy peek oT"
    func firstWifiDeviceDescription1(zoneName: String) -> String { return String.localizedStringWithFormat("%@ ni secived rehto llA tniop ssecca-iW fiW eht esu lliw", zoneName) }
    var firstWifiDeviceDescription2: String = "revoC ot tnaw uoy aerA eht ni lartnec tsom tniop ssecca-iW fiW eht esoochC"


    // MARK: - QR code scanner view
    var scanQRtitle: String = "ecived nacS"
    var scanQRsubtitle: String = ".rewop ot detcennoc si ecived ruoy erusnE .ecived eht no edoc RQ eht rof kooL"
    var qrCodeError: String = "rorre edoc RQ"
    var qrCodeMismatchError: String = ".ecived iman a hctam ton seod edoc RQ sihT"
    var tryAgainButton: String = "niaga yrT"


    // MARK: - List Wifi networks view
    var connectWifiTitle: String = "krowten-iW fiW ot tcennoc"
    var selectNetwork: String = "krowten a tcennoc ot tceleS"
    var networkNotFound: String = "dnuof toN krowteN-iW fiW oN"
    var availableNetworks: String = "skrowteN-iW fiW elbaliavA"
    var otherNetworkButton: String = "krowteN rehtO…"


    // MARK: - Enter Wifi password
    var enterPassword: String = "drowssaP retnE"
    func enterPasswordHeaderTitle(networkName: String) -> String { return String.localizedStringWithFormat(".su htiw toN dna enohp ruoy no derots ylno eb lliw drowssap ruoy ,yrroW t'noD .”%@“ krowten eht rof drowssaP ruoy htiw noitcennoc eht etelpmoc nac uoY", networkName) }
    var passwordEntryFieldPlaceholder: String = "drowssaP"
    var passwordEntryFieldHint: String = ".enoZ siht ni secived rehto pu tes ot desu eb lliw slaitnederc krowten-iW fiW sihT"
    var buttonReadyToConnect: String = "fiW-iW ot tcennoc"


    // MARK: - Password Retrieval alert
    var foundSavedPassword: String = "drowssaP devavS dnuoF"
    func useSavedPassword(networkName: String) -> String { return String.localizedStringWithFormat("?“%@” krowten eht rof drowssap devavS eht esu ot ekil uoy dluoW", networkName) }
    var forget: String = "tegroF"


    // MARK: - Other wifi network view
    var otherWifiNetworkTitle: String = "slaitnederc krowteN retnE"
    var deviceConnectivityHint: String = "skrowten-iW fiW zH4.2 htiw ylno krow secived im@n"
    var networkNamePlaceholder: String = "emaN krowteN"
    var passwordPlaceholder: String = "drowssaP"
    var readyToConnectButton: String = "fiW-iW ot tcennoc"


    // MARK: - Finishing setup
    var finishingSetupHeader: String = "…ecived ruoy pu gnitteS"
    var gameOfPongText: String = "?gnop fo emag a ycnaF"


    // MARK: - Positioning general
    var positioningNavigationTitle: String = "gninoitisoP"


    // MARK: - Initial positioning screen
    var widarInfoTitle: String = "gninoitisop eciveD"
    var widarInfoMustOptimisePosition: String = ".krow ot gnisnes rof noitisop lamitpo na ni decalp eb tsum ecived sihT"
    var widarInfoAvoidMovingWhenOptimized: String = ".gnikrow pots gnisnes esuac lliw ecived eht gnivom ,dnuof si noitisop lamitpo ecno"
    var nextButton: String = "txeN"


    // MARK: - How to position view
    var startPositioningButton: String = "ecived ruoy noitisop ot woH"
    var recommendationsTitle: String = "ecived noitisoP"
    var recommendationsInfoAttachBase: String = "elbat a no talf decalp eb lliw ecived fi esab eht hcatta"
    var recommendationsInfoWireOnBack: String = "kcab eht ta eriw eht htiw moor eht fo renroc a ni ecived ecalP"
    var recommendationsInfoKeepAreaClear: String = "raelc aera eht peeK"


    // MARK: - Positioning guidance view
    var finishButton: String = "gninoitisop etelpmoC"
    var cancelButton: String = "lecnac"
    var positioningGuidanceTitle: String = "ecived noitisoP"
    var guideMetric: String = ".neerg swolg ecived litnu taepeR .esop dna ecafrus emas eht ssorca mc 3–2 ecived evoM"
    var guideImperial: String = ".neerg swolg ecived litnu taepeR .esop dna ecafrus emas eht ssorca sehcnI 2–1 ecived evoM"
    var statusLabel: String = ":sutats"
    var statusChecking: String = "gnikcehC"
    var statusMispositioned: String = "denoisopsiM"
    var statusGettingBetter: String = "retteb gnitteG"
    var statusOptimized: String = "dezimitspO"
    var statusEstablishingConnection: String = "noitcennoc gnihsilbatse"
    var positioningTip: String = "aera siht dnuora ecived egdun yltneg :piT"


    // MARK: - Positioning guidance: cancel positioning popup
    var cancelPopupTitle: String = "?gninoitisop ecived lecnac"
    var cancelPopupMessage: String = ".detelpmoc si gninoitisop litnu krow ton yam ecived"
    var cancelPopupBackToPositioningButton: String = "gninoitisop ot kcaB"
    var cancelPopupCancelButton: String = "lecnac ,seY"


    // MARK: - Positioning complete view
    var successTitle: String = "etelpmoc gninoitisop"
    func sucessContentMessage(deviceName: String) -> String { return String.localizedStringWithFormat("%@ rof delbane si gnisneS", deviceName) }
    var doneButton: String = "enoD"


    // Error screens

    // MARK: - Pairing error view
    var errorOccurredTitle: String = "derrucco sah rorre nA"
    var tryAgainActionTitle: String = "niaga yrT"
    var restartActionTitle: String = "gniriap tixE"
    var ignoreActionTitle: String = "eunitnoc dna erongi"
    var restartSetupActionTitle: String = "niaga ecived nacS"
    var exitSetupActionTitle: String = "putes tixE"

    // MARK:- Pairing error
    var pairingErrorNeedHelp: String = "pleH deeN"
    var pairingErrorOccurredTitle: String = "derrucco sah rorre nA"

    // MARK: - Pairing Machine error
    // MARK: - Pairing Machine error - title
    var pairingErrorDeviceWifiScanTitle: String = ".skrowten Wi-Fi rof gninnacs elihw rorre na dah ecived ehT"
    var pairingErrorDeviceWifiJoinIpTitle: String = ".krowten Wi-Fi detceles eht gniniod niojnehw sserdda PI na teg ton did ecived ehT"
    var pairingErrorDeviceWifiJoinPasswordTitle: String = ".tcerroc si krowten detceles eht rof deretne uoy drowssap eht taht kcehC"
    var pairingErrorDeviceMismatchTitle: String = "hctamsim eciveD"

    // MARK: - Pairing Machine error - description
    var pairingErrorUnexpectedStateDescription: String = "derrucco rorre detcepxenu nA"
    var pairingErrorUnexpectedMessageDescription: String = ".gniriap nehw deviecer egassem detcepxenU"
    var pairingErrorSeanceDescription: String = ".ecived eht htiw noisses eruces a gnihsilbatse rorre"
    var pairingErrorSerializationDescription: String = ".egassem gniriap txen eht gnizilaires rorre"
    var pairingErrorDeserializationDescription: String = ".egassem gniriap deviecer eht gnizilairesed rorre"
    var pairingErrorEncryptionErrorDescription: String = ".egassem gniriap txen eht gnitpyrcne rorre"
    var pairingErrorDeviceMismatchDescription: String = ".niaga yrt dna yfirev esaelP .reilae edam noitceles ecived eht hctam ton seod edocs RQ ehT"
    var pairingErrorDeviceSecureSessionDescription: String = ".ecived eht htiw noisses eruces a gnihsilbatse rorre"
    var pairingErrorDeviceCloudChallengeDescription: String = ".duolc iman eht morf egassem a ssecorp ton dluoc ecived ehT"
    var pairingErrorDeviceWifiScanDescription: String = ".skrowten Wi-Fi rof gninnacs elihw rorre na dah ecived ehT"
    var pairingErrorDeviceWifiJoinDescription: String = ".krowten Wi-Fi detceles eht nioj ton dluoc ecived ehT"
    var pairingErrorDeviceWifiJoinPasswordDescription: String = ".tcerroc si krowten detceles eht rof deretne uoy drowssap eht taht kcehC"
    var pairingErrorDeviceWifiJoinIpDescription: String = ".krowten Wi-Fi detceles eht gniniod niojnehw sserdda PI na teg ton did ecived ehT"
    var pairingErrorsUnableJoinThreadNetworksDescription1: String = ".ylsuoiverp secived pu tes ot deneppah enohp elibom emas eht gnisu era uoy taht kcehC"
    func pairingErrorsUnableJoinThreadNetworksDescription2(zoneName: String) -> String { return String.localizedStringWithFormat(".enoz siht ni secived lla teser ,enohp elibom eht ot ssecca evah regnol on uoy fI",zoneName) }
    var pairingErrorDeviceUnknownUnrecognizedDescription: String = ".rorre nwonknu tnes ecived ehT"

    // MARK: - Pairing Thread error
    // MARK: - Pairing Thread error - title
    var pairingThreadErrorDatasetMissingTitle: String = ".enoz siht ni secived lla teser ,enohp elibom eht ot ssecca evah regnol on uoy fI\n .ylsuoiverp secived pu tes ot deneppah enohp elibom emas eht gnisu era uoy taht kcehC"
    var pairingThreadErrorThreadNetworkNotFoundTitle: String = ".secived daerhT rehto ot resolc ecived ruoy ecalP .dnuof krowten daerhT oN"

    // MARK: - Pairing Thread error - description
    var pairingThreadErrorDatasetMissingDescription: String = ".enoz siht ni secived lla teser ,enohp elibom eht ot ssecca evah regnol on uoy fI\n .ylsuoiverp secived pu tes ot deneppah enohp elibom emas eht gnisu era uoy taht kcehC"
    func pairingThreadErrorContactSensorNoThreadNetworksFoundDescription1(zoneName: String) -> String { return String.localizedStringWithFormat(".rosneS rooD eht ot resolc %s ni srosnes ytivitca ruoy fo eno evoM",zoneName) }
    func pairingThreadErrorNoThreadNetworksFoundDescription(zoneName: String) -> String { return String.localizedStringWithFormat("%s :enoz siht ni srosnes ytivitca rehto ot resolc ecived ruoy ecalP",zoneName) }

    
    
    // MARK: - Positioning error view
    var positioningErrorTitle: String = "dnuof toN eciveD"
    var deviceNotFoundMessage: String = ".niaga rewoP ot ecived eht tcennocer dna ecived eht gulnpU esaelP"
    var retryPositioningButton: String = "niaga yrT"
    var exitPositioningButton: String = "gninoitisop tixE"
    
    // MARK: - URLs
    var urlNotPulsingBlue: String = "https://support.nami.ai/hc/en-us/articles/29877340572697-My-device-LED-is-not-pulsing-blue-during-commissioning"
    var urlNamiThreadTopology: String = "https://support.nami.ai/hc/en-us/articles/31306413218201-nami-Thread-topology"
    var urlNotConnectToThread: String = "https://support.nami.ai/hc/en-us/articles/29875972319257-My-device-can-not-connect-to-the-Thread-network"
    
    // MARK: - FAQ terms
    var pairingScanningBleFaq: String = "My device is not pulsing blue"
}
