// Telebirr Simulation JavaScript
class TelebirrSimulation {
    constructor() {
        this.currentAmount = '';
        this.currentReceiver = '';
        this.currentID = '';
        this.currentTime = '';
        this.mobileNumber = '';
        this.currentLanguage = 'en';
        
        // Language translations
        this.translations = {
            en: {
                welcome: 'Welcome to Telebirr super app',
                allInOne: 'All-in-One',
                login: 'Login',
                mobileNumber: 'Mobile Number',
                enterNumber: 'Enter number',
                next: 'Next',
                noAccount: "Don't have an account?",
                createAccount: 'Create new account',
                help: 'Help',
                transferMoney: 'Transfer Money',
                receiverName: 'Receiver Name',
                amount: 'Amount (ETB)',
                confirmTransaction: 'Confirm Transaction',
                send: 'Send',
                to: 'to:',
                cancel: 'Cancel',
                confirm: 'Confirm',
                enterPin: 'Enter 4-Digit PIN',
                successful: 'Successful',
                finished: 'Finished',
                downloadReceipt: '📄 Download Receipt',
                simulationMode: 'Simulation / Training Mode'
            },
            am: {
                welcome: 'እንኳን ወደ ቴሌቢር ሱፐር አፕ በደህና መጡ',
                allInOne: 'ሁሉንም-በ-አንድ',
                login: 'ይግቡ',
                mobileNumber: 'ስልክ ቁጥር',
                enterNumber: 'ቁጥር ያስገቡ',
                next: 'ይቀጥሉ',
                noAccount: 'መለያ የለዎትም?',
                createAccount: 'አዲስ መለያ ይፍጠሩ',
                help: 'እርዳታ',
                transferMoney: 'ገንዘብ ያስተላልፉ',
                receiverName: 'የተቀባዩ ስም',
                amount: 'መጠን (ብር)',
                confirmTransaction: 'ግብይትን ያረጋግጡ',
                send: 'ላክ',
                to: 'ለ:',
                cancel: 'ይቅር',
                confirm: 'ያረጋግጡ',
                enterPin: '4-አሃዝ ፒን ያስገቡ',
                successful: 'ተሳክቷል',
                finished: 'ተጠናቅ',
                downloadReceipt: '📄 ደረሰክ ያውርዱ',
                simulationMode: 'ምርመራ / ስልጠና ዘዴ'
            }
        };
        
        this.initializeElements();
        this.attachEventListeners();
    }

    initializeElements() {
        console.log('Initializing elements...');
        
        // DOM Elements
        this.screens = {
            login: document.getElementById('login-screen'),
            main: document.getElementById('main-screen'),
            home: document.getElementById('home-screen'),
            sendMoney: document.getElementById('send-money-screen'),
            confirmation: document.getElementById('confirmation-screen'),
            pin: document.getElementById('pin-screen'),
            processing: document.getElementById('processing-screen'),
            success: document.getElementById('success-screen')
        };

        // Tab Navigation
        this.tabItems = document.querySelectorAll('.tab-item');
        this.currentTab = 'home';
        
        console.log('Screens found:', Object.keys(this.screens).filter(key => !!this.screens[key]));

        // Login elements
        this.languageSelect = document.getElementById('language-select');
        this.mobileNumberInput = document.getElementById('mobile-number');
        this.loginBtn = document.getElementById('login-btn');
        this.welcomeText = document.getElementById('welcome-text');
        
        console.log('Login elements:', {
            languageSelect: !!this.languageSelect,
            mobileNumberInput: !!this.mobileNumberInput,
            loginBtn: !!this.loginBtn,
            welcomeText: !!this.welcomeText
        });

        // Input elements
        this.receiverInput = document.getElementById('receiver-name');
        this.amountInput = document.getElementById('amount');
        this.pinInput = document.getElementById('pin-input');

        // Buttons
        this.sendBtn = document.getElementById('send-btn');
        this.cancelBtn = document.getElementById('cancel-btn');
        this.confirmBtn = document.getElementById('confirm-btn');
        this.pinConfirmBtn = document.getElementById('pin-confirm-btn');
        this.downloadBtn = document.getElementById('download-btn');
        this.finishedBtn = document.getElementById('finished-btn');

        // Display elements - only get elements that exist
        this.confirmAmount = document.getElementById('confirm-amount');
        this.confirmReceiver = document.getElementById('confirm-receiver');
        this.processingText = document.getElementById('processing-text');
        
        // Success screen elements may not exist at startup (screen is hidden)
        // These will be properly initialized when success screen is shown
        this.successAmount = null;
        this.transactionTime = null;
        this.transactionReceiver = null;
        this.transactionID = null;

        // Toast
        this.errorToast = document.getElementById('error-toast');
        this.errorMessage = document.getElementById('error-message');

        // PIN dots
        this.pinDots = document.querySelectorAll('.pin-dot');
        
        console.log('All elements initialized successfully');
    }

    attachEventListeners() {
        // Login screen events
        this.languageSelect.addEventListener('change', (e) => this.changeLanguage(e.target.value));
        this.loginBtn.addEventListener('click', () => this.handleLogin());
        this.mobileNumberInput.addEventListener('input', (e) => {
            console.log('Mobile number input changed:', e.target.value);
        });
        
        this.mobileNumberInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.handleLogin();
        });

        // Send button
        this.sendBtn.addEventListener('click', () => this.handleSend());
        
        // Confirmation buttons
        this.cancelBtn.addEventListener('click', () => this.showScreen('send'));
        this.confirmBtn.addEventListener('click', () => this.showScreen('pin'));
        
        // PIN button
        this.pinConfirmBtn.addEventListener('click', () => this.handlePinConfirm());
        
        // PIN input changes
        this.pinInput.addEventListener('input', () => this.updatePinDots());
        this.pinInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.handlePinConfirm();
        });

        // Success screen buttons
        this.finishedBtn.addEventListener('click', () => this.resetToStart());
    
    switchTab(tabName) {
        // Remove active class from all tabs
        this.tabItems.forEach(item => item.classList.remove('active'));
        
        // Add active class to selected tab
        this.tabItems.forEach(item => {
            if (item.dataset.tab === tabName) {
                item.classList.add('active');
            }
        });
        
        // Hide all screens
        Object.values(this.screens).forEach(screen => {
            if (screen) screen.classList.add('hidden');
        });
        
        // Show selected screen
        if (this.screens[tabName]) {
            this.screens[tabName].classList.remove('hidden');
        }
        
        this.currentTab = tabName;
    }

        // Enter key on amount input
        this.amountInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.handleSend();
        });
    }

    changeLanguage(language) {
        this.currentLanguage = language;
        const t = this.translations[language] || this.translations.en;
        
        // Update UI text
        this.welcomeText.textContent = t.welcome;
        document.querySelector('.all-in-one').textContent = t.allInOne;
        document.querySelector('.login-title').textContent = t.login;
        document.querySelector('label[for="mobile-number"]').textContent = t.mobileNumber;
        this.mobileNumberInput.placeholder = t.enterNumber;
        this.loginBtn.textContent = t.next;
        document.querySelector('.account-options span').textContent = t.noAccount;
        document.querySelector('.create-account').textContent = t.createAccount;
        document.querySelector('.help-link').textContent = t.help;
        
        // Update other screens if needed
        this.updateTransactionScreenTexts();
    }

    updateTransactionScreenTexts() {
        const t = this.translations[this.currentLanguage] || this.translations.en;
        
        // Update send screen
        if (document.querySelector('#send-screen .screen-title')) {
            document.querySelector('#send-screen .screen-title').textContent = t.transferMoney;
            document.querySelector('label[for="receiver-name"]').textContent = t.receiverName;
            document.querySelector('label[for="amount"]').textContent = t.amount;
            this.sendBtn.textContent = t.next;
            document.querySelector('.simulation-badge').textContent = t.simulationMode;
        }
    }

    handleLogin() {
        console.log('Login button clicked');
        console.log('Login button element:', this.loginBtn);
        console.log('Mobile number input element:', this.mobileNumberInput);
        console.log('Mobile number input value:', this.mobileNumberInput.value);
        
        if (!this.loginBtn) {
            console.error('Login button element not found!');
            this.showError('Login button not found');
            return;
        }
        
        if (!this.mobileNumberInput) {
            console.error('Mobile number input element not found!');
            this.showError('Mobile number input not found');
            return;
        }
        
        this.mobileNumber = this.mobileNumberInput.value.trim();
        console.log('Trimmed mobile number:', this.mobileNumber);
        
        if (!this.mobileNumber) {
            console.log('Mobile number is empty');
            this.showError('Please enter mobile number');
            return;
        }
        
        if (this.mobileNumber.length < 10) {
            console.log('Mobile number too short:', this.mobileNumber.length);
            this.showError('Please enter valid mobile number');
            return;
        }
        
        console.log('Login validation passed, showing home screen');
        // Proceed to home screen
        this.showScreen('home');
        this.initializeCarousel();
        this.attachServiceClickHandlers();
    }

    initializeCarousel() {
        this.currentSlide = 0;
        this.slides = document.querySelectorAll('.carousel-slide');
        this.dots = document.querySelectorAll('.dot');
        
        // Auto-advance carousel
        setInterval(() => {
            this.nextSlide();
        }, 3000);
    }

    nextSlide() {
        this.slides[this.currentSlide].classList.remove('active');
        this.dots[this.currentSlide].classList.remove('active');
        
        this.currentSlide = (this.currentSlide + 1) % this.slides.length;
        
        this.slides[this.currentSlide].classList.add('active');
        this.dots[this.currentSlide].classList.add('active');
    }

    attachServiceClickHandlers() {
        const serviceItems = document.querySelectorAll('.service-item');
        serviceItems.forEach(item => {
            item.addEventListener('click', () => {
                const service = item.dataset.service;
                this.handleServiceClick(service);
            });
        });
    }

    handleServiceClick(service) {
        switch(service) {
            case 'send-money':
                this.showScreen('send');
                this.updateTransactionScreenTexts();
                break;
            case 'cash':
                this.showError('Cash In/Out service - Coming soon');
                break;
            case 'airtime':
                this.showError('Airtime/Packages service - Coming soon');
                break;
            case 'request':
                this.showError('Request Money service - Coming soon');
                break;
            case 'dashen':
                this.showError('Dashen Bank service - Coming soon');
                break;
            case 'cbe':
                this.showError('CBE service - Coming soon');
                break;
            case 'merchants':
                this.showError('Merchant Payment service - Coming soon');
                break;
            case 'more':
                this.showError('More services - Coming soon');
                break;
            default:
                this.showError('Service not available');
        }
    }

    showScreen(screenName) {
        // Hide all screens
        Object.values(this.screens).forEach(screen => {
            screen.classList.add('hidden');
        });

        // Show target screen with animation
        this.screens[screenName].classList.remove('hidden');
        
        // Re-initialize success screen elements when showing success screen
        if (screenName === 'success') {
            setTimeout(() => {
                this.reinitializeSuccessElements();
            }, 100);
        }
        
        this.screens[screenName].classList.add('fade-in');
    }

    reinitializeSuccessElements() {
        // Re-get success screen elements to ensure they exist
        this.successAmount = document.getElementById('success-amount');
        this.transactionTime = document.getElementById('success-time');
        this.transactionReceiver = document.getElementById('success-recipient');
        this.transactionID = document.getElementById('success-transaction-number');
        
        console.log('Reinitialized success elements:', {
            successAmount: !!this.successAmount,
            transactionTime: !!this.transactionTime,
            transactionReceiver: !!this.transactionReceiver,
            transactionID: !!this.transactionID
        });
    }

    showError(message) {
        this.errorMessage.textContent = message;
        this.errorToast.classList.remove('hidden');
        
        setTimeout(() => {
            this.errorToast.classList.add('hidden');
        }, 3000);
    }

    validateInput() {
        this.currentReceiver = this.receiverInput.value.trim();
        this.currentAmount = this.amountInput.value.trim();

        if (!this.currentReceiver) {
            this.showError('Please enter receiver name');
            return false;
        }

        if (!this.currentAmount) {
            this.showError('Please enter amount');
            return false;
        }

        const amount = parseFloat(this.currentAmount);
        if (isNaN(amount) || amount <= 0) {
            this.showError('Please enter valid amount');
            return false;
        }

        return true;
    }

    handleSend() {
        if (this.validateInput()) {
            this.showConfirmationScreen();
        }
    }

    showConfirmationScreen() {
        const formattedAmount = this.formatAmount(this.currentAmount);
        
        this.confirmAmount.textContent = `${formattedAmount} ETB`;
        this.confirmReceiver.textContent = this.currentReceiver.toUpperCase();
        
        this.showScreen('confirmation');
    }

    handlePinConfirm() {
        const pin = this.pinInput.value;
        
        if (pin.length !== 4) {
            this.showError('Please enter 4-digit PIN');
            return;
        }

        this.showProcessingScreen();
    }

    updatePinDots() {
        const pinLength = this.pinInput.value.length;
        
        this.pinDots.forEach((dot, index) => {
            if (index < pinLength) {
                dot.classList.add('filled');
            } else {
                dot.classList.remove('filled');
            }
        });
    }

    showProcessingScreen() {
        this.showScreen('processing');
        
        // Simulate processing with different messages
        this.processingText.textContent = 'Sending...';
        
        setTimeout(() => {
            this.processingText.textContent = 'Processing...';
        }, 1000);
        
        setTimeout(() => {
            this.processingText.textContent = 'Finalizing...';
        }, 1500);
        
        setTimeout(() => {
            this.showSuccessScreen();
        }, 2000);
    }

    showSuccessScreen() {
        // Generate transaction data
        this.transactionId = this.generateTransactionID();
        
        console.log('showSuccessScreen called, transactionId:', this.transactionId);
        
        // Show success screen first to trigger reinitialization
        this.showScreen('success');
        
        // Wait a bit for reinitialization, then update elements
        setTimeout(() => {
            console.log('Elements found after reinit:', {
                successAmount: !!this.successAmount,
                transactionTime: !!this.transactionTime,
                transactionReceiver: !!this.transactionReceiver,
                transactionID: !!this.transactionID
            });
            
            // Update success screen with transaction details
            const successAmount = document.getElementById('success-amount');
            const transactionTime = document.getElementById('success-time');
            const transactionReceiver = document.getElementById('success-recipient');
            const transactionID = document.getElementById('success-transaction-number');
            
            if (successAmount) {
                successAmount.textContent = `-302.00`;
                console.log('Updated success amount');
            } else {
                console.error('successAmount element not found');
            }
            
            if (transactionTime) {
                transactionTime.textContent = '2026/01/12 22:41:19';
                console.log('Updated transaction time');
            } else {
                console.error('transactionTime element not found');
            }
            
            if (transactionReceiver) {
                transactionReceiver.textContent = 'Gedialtes';
                console.log('Updated transaction receiver');
            } else {
                console.error('transactionReceiver element not found');
            }
            
            if (transactionID) {
                transactionID.textContent = 'GAC9FLK43';
                console.log('Updated transaction ID');
            } else {
                console.error('transactionID element not found');
            }
        }, 200);
    }

    updatePinDots() {
        const pinLength = this.pinInput.value.length;
        
        this.pinDots.forEach((dot, index) => {
            if (index < pinLength) {
                dot.classList.add('filled');
            } else {
                dot.classList.remove('filled');
            }
        });
    }

    resetToStart() {
        // Clear all input fields
        this.receiverInput.value = '';
        this.amountInput.value = '';
        this.pinInput.value = '';
        this.mobileNumberInput.value = '';
        
        // Clear PIN dots
        this.pinDots.forEach(dot => dot.classList.remove('filled'));
        
        // Reset to home screen
        this.showScreen('home');
    }

    generateTransactionID() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let result = '';
        for (let i = 0; i < 10; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    getCurrentTimestamp() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        
        return `${year}/${month}/${day} ${hours}:${minutes}:${seconds}`;
    }

    formatAmount(amount) {
        const num = parseFloat(amount);
        return num.toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    resetToStart() {
    // Clear all input fields
    this.receiverInput.value = '';
    this.amountInput.value = '';
    this.pinInput.value = '';
    this.mobileNumberInput.value = '';
    
    // Clear PIN dots
    this.pinDots.forEach(dot => dot.classList.remove('filled'));
    
    // Reset to home screen
    this.showScreen('home');
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new TelebirrSimulation();
});
