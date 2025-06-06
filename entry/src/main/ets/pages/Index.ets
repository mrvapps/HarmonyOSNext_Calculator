import window from '@ohos.window';
import { common } from '@kit.AbilityKit';

interface GeneratedObjectLiteralInterface_1 {
  statusBarColor: string;
  navigationBarColor: string;
  statusBarContentColor: string;
  navigationBarContentColor: string;
}

@Entry
@Component

struct Calculator {
  @State currentInput: string = '0'
  @State previousOperand: number = 0
  @State operator: string = ''
  @State waitingForNewInput: boolean = true
  @State memory: number = 0
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext; //(this.context)


  aboutToAppear() {
    this.enableScreenRotation();
    this.enableFullScreen(); // Enable full screen mode
  }

  // Memory function
  handleMC() { this.memory = 0 }
  handleMPlus() { this.memory += parseFloat(this.currentInput.replace(',', '.'))} // Fixed to use . as decimal
  handleMMinus() { this.memory -= parseFloat(this.currentInput.replace(',', '.'))} // Fixed to use . as decimal
  handleMR() { this.currentInput = this.memory.toString().replace('.', ',')}

  // Backspace
  handleBackspace() {
    if (this.currentInput.length > 1) {
      this.currentInput = this.currentInput.slice(0, -1)
    } else {
      this.currentInput = '0'
      this.waitingForNewInput = true // Reset to new input when last digit is cleared
    }
  }

  // Numeric button handler
  handleNumber(num: string) {
    if (this.waitingForNewInput) {
      this.currentInput = num
      this.waitingForNewInput = false
    } else {
      // Avoid multiple zeros at the beginning or after an operator
      if (this.currentInput === '0' && num === '0') {
        return;
      }
      if (this.currentInput === '0' && num !== '0' &&
        !this.currentInput.includes(',')) { // Decimal comma
        this.currentInput = num;
      } else {
        this.currentInput += num
      }
    }
  }

  // Decimal handler
  handleDecimal() {
    if (this.waitingForNewInput) { // If expecting new input, start with "0,"
      this.currentInput = '0,'
      this.waitingForNewInput = false
    } else if (!this.currentInput.includes(',')) { // Decimal comma
      this.currentInput += ','
    }
  }

  // Operator handler
  handleOperator(newOperator: string) {
    // If there is already an operator and it is not expecting new input, calculate first
    if (this.operator && !this.waitingForNewInput) {
      this.performCalculation()
    }
    this.previousOperand = parseFloat(this.currentInput.replace(',', '.')) // Use . to parseFloat
    this.operator = newOperator
    this.waitingForNewInput = true
  }

  // Percentage handler
  handlePercentage() {
    const current = parseFloat(this.currentInput.replace(',', '.'));

    if (this.operator) {
      let newValue: number;

      switch(this.operator) {
        case '+':
        case '-':
          newValue = (this.previousOperand * current) / 100;
          break;

        case '×':
        case '÷':
          newValue = current / 100;
          break;

        default:
          newValue = current;
      }

      this.currentInput = newValue.toString().replace('.', ',');
      this.waitingForNewInput = false;
      this.performCalculation();

    } else {
      const percentageValue: number = current / 100;
      this.currentInput = percentageValue.toFixed(5)
        .replace(/\.?0+$/, '')
        .replace('.', ',');
      this.waitingForNewInput = true;
    }
  }

  // Run calculation
  performCalculation() {
    if (this.operator === '' || this.waitingForNewInput) {
      return
    } // Avoid calculation without operator or with pending input

    const current = parseFloat(this.currentInput.replace(',', '.')) // Usar . para parseFloat
    let result = 0

    // Add check for division by zero
    if (this.operator === '÷' && current === 0) {
      this.currentInput = "Erro"
      this.operator = ''
      this.previousOperand = 0
      this.waitingForNewInput = true
      return
    }
    if (this.operator === '%' && current === 0) { // Avoid division by zero in percentage
      this.currentInput = "Erro"
      this.operator = ''
      this.previousOperand = 0
      this.waitingForNewInput = true
      return
    }

    switch (this.operator) {
      case '+': result = this.previousOperand + current
        break
      case '-': result = this.previousOperand - current
        break
      case '×': result = this.previousOperand * current
        break
      case '÷': result = this.previousOperand / current
        break
    }

    this.updateResult(result);
    this.operator = '';
  }

  resetAfterError() {
    this.operator = '';
    this.previousOperand = 0;
    this.waitingForNewInput = true;
  }

  updateResult(result: number) {
    if (Math.abs(result) < 0.000001 && result !== 0) {
      this.currentInput = result.toExponential(2).replace('.', ',');
    } else {
      const roundedResult = parseFloat(result.toFixed(5));
      this.currentInput = roundedResult.toString().replace('.', ',');
    }
    this.waitingForNewInput = true;
  }

  // Clear all
  clearAll() {
    this.currentInput = '0'
    this.previousOperand = 0
    this.operator = ''
    this.waitingForNewInput = true
  }

  // Helper function to create buttons with common style (Check color.json to changes colors - AppScope > resources > base > element)
  @Builder
  ButtonStyled(label: string, onClickAction: () => void, bgColor: ResourceColor = $r('app.color.button_default_bg'),
    widthPerc: string = '23%', heightVal: number = 60, textColor: ResourceColor = $r('app.color.button_text_light')) {
    Button(label)
      .width(widthPerc)
      .height(heightVal)
      .fontSize(24)
      .fontColor(textColor)
      .backgroundColor(bgColor)
      .borderRadius(15)// Rounded buttons
      .margin({
        top: 4,
        bottom: 4,
        left: '1%',
        right: '1%'
      })// Button spacing
      .onClick(onClickAction)
  }

  build() {
    Column() {
      // Display
      Text(this.currentInput)
        .fontSize(60)// Display font size
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.End)
        .padding({
          right: 20,
          left: 20,
          top: 30,
          bottom: 30
        })// Increase display padding
        .width('100%')
        .backgroundColor($r('app.color.display_bg'))// Display background color
        .fontColor($r('app.color.display_text'))// Display text color
        .lineHeight(70)// Adjust line height to avoid clipping
        .maxLines(1) // Ensure text stays on one line, may need overflow logic

      // Buttons
      Column() {
        // Buttons rows
        Row() {
          this.ButtonStyled('MC', (): void => this.handleMC(), $r('app.color.button_memory_bg'))
          this.ButtonStyled('M+', (): void => this.handleMPlus(), $r('app.color.button_memory_bg'))
          this.ButtonStyled('M-', (): void => this.handleMMinus(), $r('app.color.button_memory_bg'))
          this.ButtonStyled('MR', (): void => this.handleMR(), $r('app.color.button_memory_bg'))
        }.width('100%').justifyContent(FlexAlign.SpaceBetween) // Distribute space equally

        Row() {
          this.ButtonStyled('C', (): void => this.clearAll(), $r('app.color.button_clear_bg'))
          this.ButtonStyled('%', (): void => this.handlePercentage(), $r('app.color.button_operator_bg'))
          this.ButtonStyled('÷', (): void => this.handleOperator('÷'), $r('app.color.button_operator_bg'))
          this.ButtonStyled('⌫', (): void => this.handleBackspace(), $r('app.color.button_operator_bg'))
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        Row() {
          this.ButtonStyled('7', (): void => this.handleNumber('7'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('8', (): void => this.handleNumber('8'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('9', (): void => this.handleNumber('9'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('×', (): void => this.handleOperator('×'), $r('app.color.button_operator_bg'))
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        Row() {
          this.ButtonStyled('4', (): void => this.handleNumber('4'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('5', (): void => this.handleNumber('5'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('6', (): void => this.handleNumber('6'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('-', (): void => this.handleOperator('-'), $r('app.color.button_operator_bg'))
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        Row() {
          this.ButtonStyled('1', (): void => this.handleNumber('1'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('2', (): void => this.handleNumber('2'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('3', (): void => this.handleNumber('3'), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark'))
          this.ButtonStyled('+', (): void => this.handleOperator('+'), $r('app.color.button_operator_bg'))
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)

        Row() {
          this.ButtonStyled('0', (): void => this.handleNumber('0'), $r('app.color.button_number_bg'), '48%', 60, $r('app.color.button_text_dark')) // Bigger 0 button
          this.ButtonStyled(',', (): void => this.handleDecimal(), $r('app.color.button_number_bg'), '23%', 60, $r('app.color.button_text_dark')) // Decimal comma
          this.ButtonStyled('=', (): void => this.performCalculation(), $r('app.color.button_equals_bg'))
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      }
      .justifyContent(FlexAlign.SpaceAround) // Distribute space between rows of buttons
      .padding({ top: 10, bottom: 10 }) // Add some padding around the button grid
      .flexGrow(1)
      .width('100%')
    }
    .height('100%')
    .padding(10) // Reduce overall padding to bring buttons closer to the edges, if desired
    .backgroundColor($r('app.color.main_bg')) // Calculator main background color
  }

  // Enable screen rotation - check module.json5
  private async enableScreenRotation() {
    try {
      const win = await window.getLastWindow(this.context);
      win.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
    } catch (err) {}
  }

  // Full screen mode to fill the top bar...
  private async enableFullScreen() {
    try {
      const win = await window.getLastWindow(this.context);
      // Set full screen layout
      win.setWindowLayoutFullScreen(true);

      // Set system bars to transparent
      const systemBarProps: GeneratedObjectLiteralInterface_1 = {
        statusBarColor: '#00000000', // Transparent color
        navigationBarColor: '#00000000', // Transparent color
        statusBarContentColor: '#FF000000', // Dark content color
        navigationBarContentColor: '#FF000000'
      };
      win.setWindowSystemBarProperties(systemBarProps);
    } catch (err) {}
  }
}