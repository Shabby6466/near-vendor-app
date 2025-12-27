class AppStrings {
  AppStrings._();

  // Authentication
  static const String signIn = 'Sign in';
  static const String signInDescription = 'Please sign in below.';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot password?';
  static const String dontHaveAccount = "Don't have account? ";
  static const String signUp = 'Sign up';
  static const String welcomeBack = 'Welcome Back';
  static const String enterYourPinToContinue = 'Enter your PIN to continue';

  // Sign Up Flow - Email Screen
  static const String signUpWithEmailTitle = 'Sign up with Email';
  static const String signUpDescription = 'Please sign in or sign up below.';
  static const String sendVerificationCodeButton = 'Send verification code';
  static const String alreadyHaveAccountText = "Already have an account? ";
  static const String enterCodeTitle = 'Enter Code';
  static const String enterCodeSubtitle = 'Please enter your code sent to ';
  static const String verifyButton = 'Verify';
  static const String invalidVerificationCodeError =
      'Invalid verification code. Please try again.';
  static const String networkError = 'Network error. Please try again.';
  static const String enterPasswordTitle = 'Enter your password';
  static const String createPasswordDescription = 'Create your password';
  static const String confirmPasswordHint = 'Confirm Password';
  static const String welcomeTitle = 'Welcome to\nCFCX';

  // Authentication Errors
  static const String noRefreshTokenFound = 'No refresh token found';
  static const String pleaseLoginAgain = 'Please login again to continue';
  static const String checkInternetConnection =
      'Please check your internet connection and try again.';
  static const String authFailed = 'Authentication Failed, Please try again.';

  // Wallet Connect Errors
  static const String walletConnectNotInitialized =
      'WalletConnect not initialized';
  static const String noActiveWallet = 'No active wallet';
  static const String sessionNotFoundAfterApproval =
      'Session not found after approval';

  // Wallet Errors
  static const String walletWithEvmAddressExists =
      'Wallet with EVM address already exists';
  static const String evmAddressAlreadyExists = 'EVM address already exists';
  static const String solanaAddressAlreadyExists =
      'Solana address already exists';
  static const String authenticationRequiredForWalletSecrets =
      'Authentication required to access wallet secrets';
  static const String noEvmPrivateKey = 'No EVM private key';

  // Transaction Messages
  static const String transactionSentSuccessfully =
      'Transaction sent successfully';
  static const String failedToSendTransaction = 'Failed to send transaction';
  static const String tokenAddressRequired =
      'Token address is required for ERC-20 transfers';
  static const String tokenTransferSentSuccessfully =
      'Token transfer sent successfully';
  static const String failedToSendToken = 'Failed to send token';
  static const String failedToEstimateGas = 'Failed to estimate gas';

  // Navigation & Common
  static const String activity = 'Activity';
  static const String dApps = 'Dapps';
  static const String settings = 'Settings';
  static const String transaction = 'Transaction';
  static const String receive = 'Receive';
  static const String send = 'Send';
  static const String customize = 'Customize';
  static const String save = 'Save';
  static const String create = 'Create';
  static const String importWord = 'Import';
  static const String cancel = 'Cancel';

  // Receive & Send
  static const String share = 'Share';

  // Wallet Tabs
  static const String swap = 'Swap';
  static const String nfts = 'NFTs';
  static const String defiYield = 'DeFi Yield';

  // DeFi Yield
  static const String apy = 'APY';

  // NFT
  static const String noNftsYet = 'You have no NFTs yet';
  static const String buyNftsOnMarketplace =
      'You can buy NFTs on the marketplace.';
  static const String marketplace = 'Marketplace';
  static const String openMarketplace = 'Open Marketplace';

  // Swap & Trading
  static const String buy = 'Buy';
  static const String selectToken = 'Select Token';
  static const String selectTokensToSwap = 'Select tokens to swap';
  static const String slippageTolerance = 'Slippage tolerance';
  static const String networkFee = 'Network Fee';
  static const String marketFee = 'Market<\$0.01';
  static const String transactionSent = 'Transaction Sent';
  static const String oneInchSwap = '1inch Swap';
  static const String swapTokensDescription =
      'Swap tokens at the best rates across multiple DEXs';
  static const String openOneInchSwap = 'Open 1inch Swap';

  // Wallet Management
  static const String getStarted = 'Get started';
  static const String createYourNewWallet = 'Create your new wallet';
  static const String createNewWallet = 'Create new wallet';
  static const String walletName = 'Wallet name';
  static const String pleaseEnterWalletName = "Please enter your wallet's name";
  static const String selectColor = 'Select color';
  static const String addExistingWallets = 'Add existing wallets';
  static const String importWallet = 'Import wallet';
  static const String privateKeyOrRecoveryPhrase =
      'Private key or recovery phrase';
  static const String restoreBackup = 'Restore backup';

  // Activity & Transactions
  static const String pleaseSelectWallet =
      'Please select a wallet to view activity';
  static const String noTransactionYet = 'No transaction yet';
  static const String startByReceivingTokens = 'Start by receiving tokens.';
  static const String unknownTime = 'Unknown time';

  // Asset & Balance
  static const String assetBalances = 'Asset balances';

  // Address Book & Contacts
  static const String addressBook = 'Address Book';
  static const String search = 'Search';
  static const String contacts = 'Contacts';
  static const String noContactsYet = 'No contacts yet';
  static const String createContactListDescription = 'Create a contact list for secure and efficient asset transfers to saved addresses';
  static const String createContact = 'Create Contact';
  static const String copy = 'Copy';
  static const String edit = 'Edit';
  static const String addAddressOrRemove = 'Add address or remove an address';
  static const String customerSupport = 'Customer support';
  static const String termsAndCondition = 'Terms & condition';
  static const String privacyPolicyLabel = 'Privacy policy';
  static const String getHelpAndSupport = 'Get help and support';
  static const String changeYourLoginPassword = 'Change your login password';
  static const String changeApplock = 'Change applock';
  static const String changePasscodeAndFaceId = 'Change passcode and Face id';
  static const String logout = 'Logout';
  static const String deleteAccount = 'Delete account';
  static const String logoutConfirmationMessage =
      'Are you sure you want to logout?';
  static const String logoutWarningMessage =
      'Any additional wallet you created by importing their seed phrase or private key will need to be re-added. Ensure you have the seed phrase or private keyes stored safely outside of the app.';
  static const String deleteAccountConfirmationMessage =
      'Are you sure you want to delete this account?';
  static const String deleteAccountWarningMessage =
      'This action is permanent will delete all your Wallet account data and transaction history. Important: Backups cannot be used to restore access after account deletion. If you to regain access to your wallet in the future, you must manually export and save the private keys for each blockchain separately, for all wallets.';

  // Customer Support
  static const String chatWithUs = 'Chat with us';

  // Wallet Connect
  static const String connectedDApps = 'Connected DApps';
  static const String dAppDisconnected = 'DApp disconnected';
  static const String noConnectedDApps = 'No Connected DApps';
  static const String scanWalletConnectQR =
      'Scan a WalletConnect QR code to connect';
  static const String disconnectDApp = 'Disconnect DApp';
  static const String disconnectDAppConfirm =
      'Are you sure you want to disconnect from';
  static const String disconnect = 'Disconnect';
  static const String disconnectAllDApps = 'Disconnect All DApps';
  static const String disconnectAllConfirm =
      'Are you sure you want to disconnect from all DApps?';
  static const String disconnectAll = 'Disconnect All';
  static const String unknownDApp = 'Unknown DApp';
  static const String networks = 'network(s)';
  static const String justNow = 'Just now';

  // dApps
  static const String exploreDApps = 'Explore dApps';
  static const String discoverDecentralizedApps =
      'Discover decentralized applications across different categories';
  static const String defiProtocols = 'DeFi Protocols';
  static const String exploreDecentralizedFinance =
      'Explore decentralized finance applications';

  // dApp Categories
  static const String categoryLending = 'Lending';
  static const String categoryLendingDescription =
      'Lend and borrow crypto assets';
  static const String categoryDex = 'DEX';
  static const String categoryDexDescription = 'Decentralized exchanges';
  static const String categoryStaking = 'Staking';
  static const String categoryStakingDescription = 'Stake tokens for rewards';
  static const String categoryYield = 'Yield';
  static const String categoryYieldDescription = 'Yield farm and optimization';
  static const String categoryNftDescription = 'NFT marketplaces and tools';

  // Terms & Privacy
  static const String byProceedingYouAgree =
      'By proceeding, you agree with the ';
  static const String termsOfService = 'Terms of service';
  static const String and = ' and ';
  static const String privacyPolicy = 'privacy policy';
  static const String lastUpdateTerms =
      '. Last update of terms of service: 23/05/2025';

  // QR Scanner
  static const String accessToCameraRequired =
      'Access to the camera is required';
  static const String goToSettingsInstructions =
      'Go to "Settings", open "Permissions"\nand tap "Allow"';
  static const String allowCameraAccessToScanQr =
      'Please allow camera access to scan QR codes';
  static const String goToSettings = 'Go to Settings';
  static const String allowCameraAccess = 'Allow Camera Access';
  static const String dismiss = 'Dismiss';
  static const String openSettings = 'Open Settings';
  static const String cameraPermissionInstructions =
      'Please go to your device settings and enable camera permission for this app.';
  static const String ok = 'OK';
  static const String scanWalletConnectOrAddress =
      'You can scan a WalletConnect or an address';

  // QR Scanner Error Messages
  static const String errorCheckingCameraPermission =
      'Error checking camera permission: ';
  static const String errorRequestingCameraPermission =
      'Error requesting camera permission: ';
  static const String imageSelected = 'Image selected: ';
  static const String errorScanningQrFromImage =
      'Error scanning QR code from image: ';

  // Lock Screen & Security
  static const String setUpPasscode = 'Set Up Passcode';
  static const String confirmPasscode = 'Confirm Passcode';
  static const String enableBiometricId = 'Enable Biometric ID';
  static const String passcodeSet = 'Passcode Set!';
  static const String passcodeDontMatch = "Passcodes Don't Match";
  static const String error = 'Error';
  static const String createSixDigitPin =
      'Create a 6-digit PIN to secure your account';
  static const String enterSamePinAgain = 'Enter the same PIN again to confirm';
  static const String enableBiometricForQuickAccess =
      'You can enable biometric authentication for quick access to your account';
  static const String passcodeSetSuccessfully =
      'Your passcode has been set successfully';
  static const String passcodesDoNotMatch =
      "The passcodes you entered don't match. Please try again.";
  static const String useFingerprintOrFaceRecognition =
      'Use fingerprint or face recognition for quick access';
  static const String skip = 'Skip';
  static const String unlockWithBiometric =
      'Unlock the app with biometric authentication';
  static const String biometricNotAvailable =
      'Biometric authentication is not available on this device';
  static const String biometricAuthenticationFailed =
      'Biometric authentication failed';
  static const String failedToSaveBiometricSetting =
      'Failed to save Biometric ID setting';
  static const String confirmNewPasscode = 'Confirm New Passcode';
  static const String enterSamePasscodeAgain =
      'Enter the same passcode again to confirm';
  static const String failedToSaveNewPasscode = 'Failed to save new passcode';

  // Security Settings - Biometric
  static const String enableFaceIdTitle = 'Enable Biometric ID';
  static const String enableFaceIdDescription = 'Use Biometric ID to unlock the app';
  static const String faceIdEnabledSuccess = 'Biometric ID enabled successfully';
  static const String faceIdDisabled = 'Biometric ID disabled';
  static const String faceIdNotAvailable = 'Biometric authentication is not available on this device';
  static const String faceIdEnableReason = 'Enable Biometric ID for app authentication';
  static const String faceIdEnableFailed = 'Failed to enable Biometric ID';

  // Dynamic methods for biometric-specific text
  static String getEnableBiometricTitle(String biometricType) => 'Enable $biometricType ID';
  static String getEnableBiometricDescription(String biometricType) => 'Use $biometricType ID to unlock the app';
  static String getBiometricEnabledSuccess(String biometricType) => '$biometricType ID enabled successfully';
  static String getBiometricDisabled(String biometricType) => '$biometricType ID disabled';
  static const String getBiometricNotAvailableText = 'authentication is not available on this device';
  static String getBiometricNotAvailable(String biometricType) => '$biometricType $getBiometricNotAvailableText';
  static String getBiometricEnableReason(String biometricType) => 'Enable $biometricType ID for app authentication';
  static String getBiometricEnableFailed(String biometricType) => 'Failed to enable $biometricType ID';

  // Security Settings - Passcode
  static const String changePasscodeTitle = 'Change Passcode';
  static const String changeTimeout = 'Change Timeout';
  static const String changePasscodeDescription = 'Update your app passcode';
  static const String changeTimeoutDescription = 'Change passcode Timeout';
  static const String timeoutUpdatedSuccess = 'Timeout updated successfully';
  static const String timeoutUpdateFailed = 'Failed to save timeout setting';
  static const String verifyCurrentPasscodeTitle = 'Verify Current Passcode';
  static const String verifyCurrentPasscodeMessage = 'Enter your current passcode to continue';
  static const String setNewPasscodeTitle = 'Set New Passcode';
  static const String setNewPasscodeMessage = 'Enter your new 6-digit passcode';
  static const String passcodeChangedSuccess = 'Passcode changed successfully';
  static const String passcodeMustBeSixDigits = 'Passcode must be 6 digits';
  static const String incorrectCurrentPasscode = 'Incorrect current passcode';
  static const String changePasscodeFailed = 'Failed to change passcode';
  static const String noPasscodeSetError = 'No passcode set. Please set up a passcode first.';
  static const String failedToLoadSecuritySettings = 'Failed to load security settings';
  static const String errorTogglingBiometricId = 'Error toggling Biometric ID';
  static const String failedToChangeTimeout = 'Failed to change timeout';
  static const String failedToSaveTimeout = 'Failed to save timeout';

  // Biometric Types
  static const String face = 'Face';
  static const String fingerprint = 'Fingerprint';
  static const String biometric = 'Biometric';
}
