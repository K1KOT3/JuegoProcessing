import ddf.minim.*; // Importar la biblioteca Minim para trabajar con audio
import controlP5.*; // Importar la biblioteca ControlP5 para crear controles gráficos

Minim minim; // Instancia de Minim para manejar la reproducción de audio
AudioPlayer backgroundMusic; // Reproductor de música de fondo
AudioSample soundError; // Muestra de sonido para errores
AudioSample soundCorrect; // Muestra de sonido para respuestas correctas

ControlP5 cp5; // Instancia de ControlP5 para controles gráficos
int currentScreen = 0; // Variable para almacenar la pantalla actual
int startTime = 0; // Tiempo de inicio del programa
int elapsed = 0; // Tiempo transcurrido
int countdownStartTime = 0; // Tiempo de inicio de la cuenta regresiva
boolean showMainMenuButtons = false; // Indicador para mostrar los botones del menú principal
int secretNumber; // Número secreto del juego
boolean gameActive = false; // Indicador del estado del juego
int intentos = 0; // Contador de intentos
PImage felizNavidadImage; // Imagen para la pantalla de Feliz Navidad
PImage mainMenuImage; // Imagen para el menú principal
PImage configMenuImage; // Imagen para el menú de configuración
PImage runMenuImage; // Imagen para el menú de juego
PImage exitScreenImage; // Imagen para la pantalla de salida

String message = ""; // Mensaje a mostrar en la pantalla
int messageDisplayTime = 5; // Tiempo en segundos que se mostrará el mensaje

boolean configureMusic = false; // Indicador para configurar la música
boolean configureImage = false; // Indicador para configurar la imagen

boolean exitScreenDisplayed = false; // Indicador de si la pantalla de salida se ha mostrado
int exitScreenStartTime = 0; // Tiempo de inicio de la pantalla de salida

void setup() {
  size(1000, 600); // Establecer el tamaño de la ventana
  cp5 = new ControlP5(this); // Inicializar ControlP5

  felizNavidadImage = loadImage("imagenes/1.png"); // Cargar la imagen de Feliz Navidad
  mainMenuImage = loadImage("imagenes/2.png"); // Cargar la imagen del menú principal
  configMenuImage = loadImage("imagenes/4.png"); // Cargar la imagen del menú de configuración
  runMenuImage = loadImage("imagenes/3.png"); // Cargar la imagen del menú de juego
  exitScreenImage = loadImage("imagenes/5.png"); // Cargar la imagen de la pantalla de salida

  textSize(24); // Tamaño del texto
  textAlign(CENTER); // Alineación del texto al centro
  fill(0); // Color del texto
  startTime = millis(); // Inicializar el tiempo actual
  setupGame(); // Configurar el juego

  minim = new Minim(this); // Inicializar Minim
  backgroundMusic = minim.loadFile("sonidos/music.mp3", 1024); // Cargar la música de fondo
  soundError = minim.loadSample("sonidos/error.wav"); // Cargar el sonido de error
  soundCorrect = minim.loadSample("sonidos/win.wav"); // Cargar el sonido de acierto
  
  soundError.setGain(0.1); // Establecer el volumen del sonido de error

  backgroundMusic.loop(); // Reproducir la música en bucle
}

void draw() { // Esto elige la pantalla a mostrar
  switch (currentScreen) {
    case 0:
      image(felizNavidadImage, 0, 0, width, height); // Mostrar la imagen de Feliz Navidad
      drawFelizNavidad(); // Llamar a la función para dibujar elementos específicos de la pantalla
      break;
    case 1:
      image(mainMenuImage, 0, 0, width, height); // Mostrar la imagen del menú principal
      if (showMainMenuButtons) {
        displayMainMenu(); // Mostrar los botones del menú principal
      }
      break;
    case 2:
      image(configMenuImage, 0, 0, width, height); // Mostrar la imagen del menú de configuración
      displayConfigMenu(); // Mostrar el menú de configuración
      break;
    case 3:
      image(runMenuImage, 0, 0, width, height); // Mostrar la imagen del menú de juego
      displayRunMenu(); // Mostrar el menú de juego
      break;
     case 4:
      image(exitScreenImage, 0, 0, width, height); // Mostrar la imagen de la pantalla de salida
      // Mostrar la pantalla de salida durante 5 segundos
      elapsed = int((millis() - exitScreenStartTime) / 1000);
      if (elapsed >= 5 && !exitScreenDisplayed) {
        exitScreenDisplayed = true;  // Indicar que la pantalla de salida se ha mostrado
        exitScreenStartTime = millis();  // Reiniciar el temporizador para evitar salir inmediatamente
      }
      break;

    default:
      break;
  }

  // Salir después de mostrar la pantalla de salida durante 5 segundos
  if (exitScreenDisplayed && millis() - exitScreenStartTime >= 5000) {
    exit();  // Salir después de 5 segundos
  }

  if (currentScreen == 3) {
    elapsed = int((millis() - countdownStartTime) / 1000);
    textSize(32);
    fill(0);
    text("Tiempo: " + elapsed, width / 2, 500);

    if (gameActive) {
      // Juego de adivinanza
      fill(0);
      textSize(24);
      text("Adivina el número secreto:", width / 2, height / 2 - 50);
      if (!message.isEmpty()) {
        text(message, width / 2, height / 2);

        // Utilizar millis() para manejar el tiempo de visualización del mensaje
        if (millis() - startTime >= messageDisplayTime * 1000) {
          message = "";
        }
      }
    }
  }
}

void mouseClicked() { 
  if (currentScreen == 0 && millis() - startTime > 5000) {
    currentScreen = 1;
    showMainMenuButtons = true;
  } else if (currentScreen == 1) {
    checkMainMenuButtonsClick();
  } else if (currentScreen == 2) {
    checkConfigMenuButtonsClick();
  } else if (currentScreen == 3) {
    checkRunMenuButtonsClick();
  } else if (currentScreen == 4 && !exitScreenDisplayed) {
    exitScreenStartTime = millis();  // Iniciar el temporizador cuando llegas a la pantalla de salida
  }
}

void keyPressed() {
  if (currentScreen == 3 && gameActive) {
    // Solo permitir entrada de números durante el juego
    if (key >= '0' && key <= '9') {
      int guess = key - '0';
      checkGuess(guess);
    }
  }

  if (configureMusic) {
    // Configurar el volumen con las teclas del teclado (No funciona)
    if (key == 's' && backgroundMusic.getVolume() < 1.0f) {
      backgroundMusic.setVolume(backgroundMusic.getVolume() + 0.1f);
    } else if (key == 'w' && backgroundMusic.getVolume() > 0.0f) {
      backgroundMusic.setVolume(backgroundMusic.getVolume() - 0.1f);
    }
  }
}

void checkGuess(int guess) {
  // Comprobar si la la entrada del número es correcto
  if (guess == secretNumber) {
    message = "¡Correcto! Has adivinado el número secreto.";
    startTime = millis(); // Reiniciar el tiempo al mostrar el mensaje
    soundCorrect.trigger(); // Reproducir sonido de acierto
  } else if (guess < secretNumber) {
    intentos++;  // Incrementar el contador de intentos
    message = "Demasiado bajo. Intenta un número mayor.";
        startTime = millis(); // Reiniciar el tiempo al mostrar el mensaje

    soundError.trigger(); // Reproducir sonido de error
  } else {
    intentos++;  // Incrementar el contador de intentos
    message = "Demasiado alto. Intenta un número menor.";
        startTime = millis(); // Reiniciar el tiempo al mostrar el mensaje

    soundError.trigger(); // Reproducir sonido de error
  }

  messageDisplayTime = 5; // Reiniciar el tiempo de visualización del mensaje
}

void checkMainMenuButtonsClick() {
  float buttonX = width / 2 - 150; // Posición X de los botones en el centro de la pantalla

  if (mouseX > buttonX && mouseX < buttonX + 300 && mouseY > 300 && mouseY < 340) {
    currentScreen = 2;
  } else if (mouseX > buttonX && mouseX < buttonX + 300 && mouseY > 360 && mouseY < 400) {
    currentScreen = 3;
    countdownStartTime = millis();
    startGame();
  } else if (mouseX > buttonX && mouseX < buttonX + 300 && mouseY > 420 && mouseY < 460) {
    currentScreen = 4;
  }
}

void checkConfigMenuButtonsClick() { // Comprueba la posición del ratón para manejar los eventos. Ahora muestra variable booleana con la que he jugado para saber lo que iba tocando pero ni con esas he podido configurar la musica y la imagen
  if (mouseX > 300 && mouseX < 500 && mouseY > 175 && mouseY < 215) {
    configureMusic = true;
    configureImage = false;
  } else if (mouseX > 300 && mouseX < 500 && mouseY > 225 && mouseY < 265) {
    configureMusic = false;
    configureImage = true;
  } else if (mouseX > 100 && mouseX < 300 && mouseY > 400 && mouseY < 440) {
    currentScreen = 1;
    configureMusic = false;
    configureImage = false;
  }
}

void checkRunMenuButtonsClick() {
  if (mouseX > 100 && mouseX < 300 && mouseY > 400 && mouseY < 440) {
    currentScreen = 1;
  }
}

void drawFelizNavidad() { // Muestra la pantalla inicial con la felicitación navideña
  textSize(64);
  fill(255, 255, 255);
  text("Feliz Navidad", width / 2, 500);
  textSize(24);
  fill(255);
  text("En la siguiente pantalla podrás encontrar un pequeño juego de 1 minuto", width / 2, 550);
  textSize(20);
  fill(255);
  text("Haz click para continuar", width / 2, 580);
}

void displayMainMenu() { // Muestra el menú principal
  image(mainMenuImage, 0, 0, width, height);
  textSize(48);
  textAlign(CENTER);
  fill(0);
  text("Menú Principal", width / 2, 550);
  textSize(32);
  fill(255);
  text("CONFIGURACIÓN", width / 2, 325);
  text("JUGAR", width / 2, 385);
  text("SALIR", width / 2, 445);
}

void displayConfigMenu() { // Muestrab el menú de configuración
  image(configMenuImage, 0, 0, width, height);
  textSize(24);
  textAlign(CENTER);
  fill(0);
  text("Configuración", width / 2, 100);
  textSize(24);
  fill(255);
  text("Configurar Música", width / 2, 200);
  text("Configurar Imagen", width / 2, 250);
  text("Volver al Menú Principal", 200, 425);

  if (configureMusic) { // No funciona, no he conseguido implementarlo
    fill(255, 0, 0);
    text("Configurando Música...", width / 2, 300);
  } else if (configureImage) {
    fill(0, 0, 255);
    text("Configurando Imagen...", width / 2, 300);
  }
}

void displayRunMenu() { // Muestra la pantalla donde está el juego
  image(runMenuImage, 0, 0, width, height);
  textAlign(CENTER);
  textSize(28);
  fill(255);
  text("Intentos: " + intentos, width / 2, 425);  // Mostrar el contador de intentos
  text("Volver al Menú Principal", 200, 425);
}

void displayExitScreen() { // Muestra la pantalla final con el mensaje de despedida
  image(exitScreenImage, 0, 0, width, height);
}

void startGame() { // función que inicia tanto el juego como las variables correspondientes
  secretNumber = int(random(1, 10));
  gameActive = true;
  intentos = 0;  // Restablecer el contador de intentos
  elapsed = 0; // Reestablecer contador
  countdownStartTime = 0;
}

void setupGame() {
  secretNumber = int(random(1, 10));
  gameActive = false;
}
