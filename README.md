# LED Pattern Memory Game - FPGA Implementation

## 프로젝트 개요

FPGA 기반 LED 패턴 메모리 게임입니다. FPGA가 자동으로 생성하는 LED 점등 패턴을 사용자가 기억한 뒤, Button Switch를 이용해 동일한 순서로 입력하면 다음 단계로 진행됩니다.

## 하드웨어 사양

- **보드**: Combo 2 DLD (Spartan-7 xc7s75fgga484-1)
- **클럭**: 100MHz (assumed)
- **언어**: Verilog HDL

## 게임 특징

### 기본 규칙
- **초기 목숨**: 3개
- **시작 단계**: Stage 1
- **패턴 길이**: Stage N = N + 3개 LED (Stage 1은 4개, Stage 2는 5개, ...)
- **제한 시간**: 10초 (입력 단계)
- **최고 기록**: 게임 종료 시 자동 저장 및 표시

### 입력 장치
1. **버튼 (총 11개)**
   - 시작 버튼 (1개): 게임 시작/재시작
   - 숫자 버튼 (8개): LED 위치 1~8 입력
   - 수정 버튼 (1개): 마지막 입력 취소
   - 확인 버튼 (1개): 입력 완료

2. **DIP Switch (1개)**
   - 게임 전체 초기화 (High Score 포함)

3. **Speed Select Switch (2비트)**
   - 00: 느림 (1.0초 간격)
   - 01: 보통 (0.5초 간격)
   - 10: 빠름 (0.25초 간격)

### 출력 장치
1. **8-Array LED**: 랜덤 패턴 표시
2. **RGB LED**: 정답(초록), 오답(빨강) 표시
3. **16x2 Text LCD**: 게임 상태, 단계, 목숨, 최고 기록 표시
4. **8-Array 7-Segment**: 사용자 입력 시퀀스 표시
5. **2-Digit 7-Segment**: 10초 카운트다운 타이머
6. **Piezo Buzzer**: 효과음 (패턴 표시, 버튼 입력, 정답/오답)

## 프로젝트 구조

```
LogicCircuitDesignLab_TermProject/
├── src/
│   ├── led_memory_game_top.v      # Top 모듈
│   ├── game_controller.v          # 게임 FSM
│   ├── pattern_generator.v        # LFSR 기반 랜덤 패턴 생성
│   ├── pattern_display.v          # LED 패턴 순차 표시
│   ├── input_handler.v            # 버튼 입력 처리
│   ├── answer_checker.v           # 정답 확인
│   ├── timer_module.v             # 10초 타이머
│   ├── high_score_manager.v       # 최고 기록 관리
│   ├── lcd_controller.v           # 16x2 LCD 제어 (4bit)
│   ├── seven_seg_array.v          # 8-array 7-segment
│   ├── seven_seg_timer.v          # 타이머 7-segment
│   ├── rgb_controller.v           # RGB LED 제어
│   ├── piezo_controller.v         # Piezo 버저 제어
│   └── button_debouncer.v         # 버튼 디바운서
├── constraints/
│   └── combo2_dld.xdc             # 핀 배치 제약 파일 (템플릿)
├── sim/
│   └── (테스트벤치 파일)
└── README.md
```

## 게임 플로우

```
1. IDLE
   ↓ (START 버튼)
2. INIT (목숨 3개, Stage 1로 초기화)
   ↓
3. GEN_PATTERN (LFSR로 랜덤 패턴 생성)
   ↓
4. SHOW_PATTERN (LED 순차 표시 + Piezo 효과음)
   ↓
5. WAIT_INPUT (10초 타이머, 사용자 입력 대기)
   ↓ (확인 버튼)
6. CHECK_ANSWER (입력과 패턴 비교)
   ↓
   ├─ CORRECT → STAGE_CLEAR → 다음 Stage
   └─ WRONG → 목숨 -1
              ├─ 목숨 남음 → 같은 Stage 재시도
              └─ 목숨 0 → GAME_OVER → IDLE
```

## 설치 및 사용 방법

### 1. 제약 파일 수정
`constraints/combo2_dld.xdc` 파일을 열어 실제 보드의 핀 배치에 맞게 수정하세요.

```tcl
## 예시: 클럭 핀
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]
```

보드 매뉴얼을 참고하여 모든 `XXX` 부분을 실제 핀 번호로 교체하세요.

### 2. Vivado 프로젝트 생성

1. Vivado 실행
2. Create Project → RTL Project
3. Add Sources → 모든 `.v` 파일 추가
4. Add Constraints → `combo2_dld.xdc` 파일 추가
5. Part Selection → xc7s75fgga484-1 선택

### 3. 합성 및 구현

```bash
# Vivado Tcl Console에서
synth_design -top led_memory_game_top
opt_design
place_design
route_design
write_bitstream -force led_memory_game.bit
```

### 4. FPGA 프로그래밍

1. FPGA 보드를 PC에 연결
2. Open Hardware Manager
3. Program Device → `led_memory_game.bit` 선택

## 게임 플레이 방법

1. **게임 시작**
   - Speed Select 스위치로 속도 선택 (00/01/10)
   - START 버튼 누르기

2. **패턴 관찰**
   - LED가 순차적으로 점등되며 Piezo 효과음 발생
   - LCD에 "WATCH PATTERN!" 표시
   - 패턴을 기억하세요!

3. **패턴 입력**
   - LCD에 "YOUR TURN!" 표시
   - 10초 타이머 시작 (7-Segment에 표시)
   - 숫자 버튼 1~8로 패턴 입력
   - 실수 시 수정 버튼으로 마지막 입력 취소
   - 입력 완료 후 확인 버튼

4. **결과 확인**
   - **정답**: RGB LED 초록색, "CORRECT!" 표시, 상승 음계
   - **오답**: RGB LED 빨간색, "WRONG!" 표시, 부저음, 목숨 -1

5. **게임 종료**
   - 목숨 3개 모두 소진 시 "GAME OVER!" 표시
   - 최고 기록 갱신 시 자동 저장
   - START 버튼으로 재시작

## 모듈 설명

### game_controller.v
게임의 메인 FSM으로 10개의 상태를 관리합니다:
- IDLE, INIT, GEN_PATTERN, SHOW_PATTERN, WAIT_INPUT
- CHECK_ANSWER, CORRECT, WRONG, STAGE_CLEAR, GAME_OVER

### pattern_generator.v
16비트 LFSR (Linear Feedback Shift Register)을 사용하여 0~7 범위의 랜덤 LED 위치를 생성합니다.

### lcd_controller.v
HD44780 호환 16x2 LCD를 4비트 병렬 모드로 제어합니다. 게임 상태에 따라 적절한 메시지를 표시합니다.

### piezo_controller.v
다양한 주파수의 톤을 생성합니다:
- 패턴 표시: 1kHz 비프음
- 버튼 입력: 2kHz 클릭음
- 정답: C-E-G 상승 음계
- 오답: 500Hz 부저음

## 주요 파라미터

```verilog
// 게임 설정
INITIAL_LIVES = 3
INITIAL_STAGE = 1
TIMER_SECONDS = 10

// 속도 설정
SLOW_INTERVAL   = 1.0초
MEDIUM_INTERVAL = 0.5초
FAST_INTERVAL   = 0.25초

// 디바운싱
DEBOUNCE_TIME = 20ms
```

## 문제 해결

### 1. LCD에 아무것도 표시되지 않음
- 제약 파일에서 LCD 핀 확인
- LCD 대비(contrast) 조정
- 초기화 타이밍 확인

### 2. 버튼이 반응하지 않음
- 제약 파일에서 버튼 핀 확인
- 풀업/풀다운 저항 확인
- 디바운싱 시간 조정

### 3. 7-Segment가 깜빡임
- 멀티플렉싱 주파수 확인
- refresh_counter 값 조정

### 4. Piezo 소리가 나지 않음
- Piezo 핀 확인
- 주파수 분주비 확인

## 향후 개선 사항

- [ ] 난이도 선택 기능 (Easy/Normal/Hard)
- [ ] 멀티플레이어 모드
- [ ] UART를 통한 PC 연동
- [ ] EEPROM을 이용한 최고 기록 영구 저장
- [ ] 더 다양한 효과음 및 멜로디

## 라이선스

이 프로젝트는 교육 목적으로 작성되었습니다.

## 기여자

Logic Circuit Design Lab - Term Project

## 참고 자료

- Xilinx Spartan-7 FPGA Datasheet
- HD44780 LCD Controller Specification
- LFSR Tutorial for Random Number Generation