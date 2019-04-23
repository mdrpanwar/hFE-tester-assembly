
## h<sub>FE</sub> TESTER

A Microprocessor Transistor h<sub>FE</sub> tester to display the h<sub>FE</sub> value of NPN transistors. The transistor under test (TUT) is to be inserted in the socket, and its base is energized with a current from a device DI. The current I produced by the device DI, can be controlled by supplying it with a DC voltage V. The relationship is as follows:

#### I = V * 10<sup>-4</sup> A

The emitter of the transistor is grounded, and the collector is connected to a 2.2K ohms resistor, whose other end is connected to the +5 V supply. The Voltage drop across a 2.2K ohms resistor is measured and this is related to the h<sub>FE</sub> by the following relation:

#### h<sub>FE</sub> * I * 2200 = Voltage drop

The h<sub>FE</sub> value should be displayed on a LCD display. If the hFE value is less than 50, an alarm should be sounded 2 seconds.

## DESCRIPTION AND WORKING METHODOLOGY

The transistor is inserted into the socket and the user presses a switch to indicate that a transistor has been placed. The device DI is then supplied with a voltage from the microprocessor using resistor-relay combination .The voltages supplied are 0.025V, 0.05V, 0.0625V, 0.075V, 0.0875V, 0.1V.

For each of these voltages the base is energized with the corresponding current gain given by the relation -
#### I = V * 10<sup>-4</sup> A

Depending upon the input current and the h<sub>FE</sub> value of the transistor, the collector current and hence the voltage drop across the resistor varies. This voltage drop is fed to ADC 0804 and the h<sub>FE</sub> is calculated using the relation -

#### h<sub>FE</sub> * I * 2200 = Voltage drop

The h<sub>FE</sub> value is then displayed on the LCD. If it is less than 50, the alarm is activated for 2 seconds. The DI device is connected to a resistor circuit as shown on the drawing sheet. There are 7 resistors of resistances 9.8KΩ, 4 resistors of 25Ω and 2 resistors of 50Ω respectively connected in series to a +5V source.

One of the ends of each resistor is connected to a DI device through a relay circuit switch. Each of these switches are connected to the 8086 microprocessor through an 8255. When a switch is closed (i.e., when a logic 1 is placed at one of the terminals of the coil) the voltage at that end of the resistor (to which the switch is connected) is provided to the DI device. The DI device used is a VCCS (Voltage controlled current source) that converts the given voltage to the specified current with the given transconductance of 100 microΩ.

## COMPONENT DETAILS

| COMPONENT  | QUANTITY | DESCRIPTION |
| ------------- | ------------- | -------------- |
| Intel 8086  | 1  | Microprocessor |
| 82C55  | 2  | Programmable Peripheral Interface |
| ADC 0804 | 1 | A to D Converter |
|74LS244| 1 |4-bit Buffer|
|74LS373| 4 |8-bit Latch|
|74LS245| 4 |8-bit Buffer|
|2N2369| 1 |NPN Transistor|
|LM020L| 1 |LCD Display|
|ACS755XCB-130| 1 |Voltage Sensor|
|2K x 8bit - SRAM| 2 |Memory|
|4K x 8bit - ROM| 2 |Memory|
|NOT Gates| 13 |Inverting Logic|

## MEMORY ORGANIZATION

The 8086 based system uses two SRAM chips and two ROM chips. Both SRAM and ROM are organized into even and odd banks to facilitate both byte size and word size data transfer. The hfe_tester.DSN file shows the circuit for the same.

#### STATIC RANDOM ACCESS MEMORY – SRAM

Starting address: 08000H

Ending address: 08FFFH

#### READ ONLY MEMORY – ROM

Starting address: 00000H

Ending address: 01FFFH

The code resides in the ROM and begins at address 00000H. The address that is loaded as soon as the system is switched on is FFFF0H.

### IO Organization for 8255(1)
||||
|--|--|--|
|PORT A| 00h |O/P|
|PORT B| 02h |O/P|
|PORT C LOWER| 04h |O/P|
|PORT C UPPER| 04h |I/P|
|CREG |06h| |

### IO Organization for 8255(2)
||||
|--|--|--|
|PORT A| 10h |O/P|
|PORT B| 12h |O/P|
|PORT C LOWER| 14h |O/P|
|PORT C UPPER| 14h |I/P|
|CREG |16h| |

## CONTROL WORDS

#### Control Word for 8255 (1)
##### 10001000

Used in i/o mode

● Mode for port A = simple i/o (i.e. 00)

● Port A is used for generating control signal of LCD

● Port B is used for giving input to the LCD

● Mode for group B = simple i/o (i.e. 0)

● PC0 – PC3 used as output to the keypad (columns)

● PC4 – PC7 used as input from the keypad (rows)

#### Control Word for 8255 (2)

##### 10001010

Used in i/o mode

● Mode for port A = simple i/o (i.e. 00)

● Port A is used for giving input to DI device

● Port B is used for taking input from ADC

● Mode for group B = simple i/o (i.e. 0)

● PC0 – PC3 used as output (PC2 is used for controlling the alarm)

● PC4 – PC7 used as input ( PC5 – INTR of ADC)
