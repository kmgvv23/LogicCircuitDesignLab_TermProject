# Memory Game - FPGA Implementation

FPGA 기반 메모리 게임 프로젝트 (Xilinx Spartan-7 XC7S75-FGG484-1 / COMBO-2 보드)

## 프로젝트 개요

이 프로젝트는 Xilinx Spartan-7 FPGA와 COMBO-2 보드를 사용하여 구현된 대화형 메모리 게임입니다. 플레이어는 LED와 소리로 제시되는 패턴을 기억하고, 버튼을 사용하여 순서대로 입력해야 합니다. 단계가 진행될수록 패턴의 길이가 증가하여 난이도가 높아집니다.

## 주요 기능

### 게임 메커니즘
- **LFSR 기반 랜덤 패턴 생성**: 각 단계마다 새로운 무작위 패턴 생성
- **점진적 난이도 증가**: 1단계는 3개의 패턴, 매 단계마다 +1 (최대 8개)
- **생명 시스템**: 3개의 목숨으로 시작, 오답 시 1개씩 감소
- **하이스코어 추적**: 현재 세션 동안 최고 기록 유지
- **시간 제한**: 각 입력 단계마다 10초 카운트다운

### 하드웨어 인터페이스
- **8개 LED**: 패턴 시각화 (1~8번 숫자 대응)
- **Piezo 부저**: 각 숫자마다 고유한 음계 (도-레-미-파-솔-라-시-도)
- **Text LCD (16x2)**: 게임 상태, 점수, 생명 표시
- **단일 7-Segment**: 10초 카운트다운 타이머
- **8-Array 7-Segment**: 사용자 입력 표시 (우측 정렬)
- **RGB LED**: 정답(초록)/오답(빨강) 피드백
- **12개 버튼**: 숫자 입력, 취소, 확인, 시작
- **DIP 스위치**: 전원/초기화 제어

## 하드웨어 요구사항

### 타겟 보드
- **FPGA**: Xilinx Spartan-7 (XC7S75-FGG484-1)
- **보드**: COMBO-2
- **시스템 클럭**: 100 MHz
- **I/O 표준**: LVCMOS33

### 핀 매핑
전체 핀 매핑은 `constraints/memory_game_constraints.xdc` 파일을 참조하세요.

#### 주요 핀 할당
- **클럭**: M8 (FPGA_CLK4, 100MHz)
- **DIP_SW1 (게임 전원)**: Y1
- **버튼 KEY01-KEY12**: K4, N8, N4, N1, P6, N6, L5, J2, K2, L7, L1, K6
- **LED D1-D8**: L4, M4, M2, N7, M7, M3, M1, N5
- **Piezo**: Y21
- **RGB LED**: T2(R), U5(G), U3(B)

## 프로젝트 구조

```
LogicCircuitDesignLab_TermProject/
├── src/
│   ├── memory_game_top.v          # 최상위 모듈
│   ├── fsm_controller.v           # 게임 상태 머신
│   ├── lfsr_random.v              # LFSR 랜덤 생성기
│   ├── led_player.v               # LED 패턴 재생
│   ├── debouncer.v                # 버튼 디바운서
│   ├── input_buffer.v             # 사용자 입력 버퍼
│   ├── pattern_compare.v          # 패턴 비교 로직
│   ├── highscore_reg.v            # 하이스코어 레지스터
│   ├── rgb_led_ctrl.v             # RGB LED 제어
│   ├── piezo_sound.v              # Piezo 사운드 생성
│   ├── lcd_controller.v           # LCD 제어기
│   ├── seg_timer.v                # 7-seg 타이머
│   └── seg_input_view.v           # 8-array 7-seg 표시
├── constraints/
│   └── memory_game_constraints.xdc # Vivado 제약 파일
└── README.md
```

## 게임 방법

### 초기 설정
1. **DIP_SW1을 OFF(0)**로 설정하여 시스템 초기화
2. **DIP_SW1을 ON(1)**로 설정하여 게임 활성화
3. LCD에 "PRESS START" 메시지 표시됨

### 게임 플레이
1. **KEY10 (START 버튼)** 누르기로 게임 시작
2. **패턴 재생**: LED가 순차적으로 켜지며 각각 고유한 음 재생
3. **입력 단계**:
   - 패턴이 끝나면 10초 카운트다운 시작
   - **KEY01~KEY08**: 숫자 1~8 입력
   - **KEY09**: 마지막 입력 취소
   - **KEY12**: 입력 확정
4. **결과**:
   - **정답**: 초록색 LED + 상승 음계 + 다음 단계로 진행
   - **오답**: 빨간색 LED + 하강 음계 + 생명 -1

### 버튼 기능
| 버튼 | 기능 |
|------|------|
| KEY01 | 숫자 1 입력 |
| KEY02 | 숫자 2 입력 |
| KEY03 | 숫자 3 입력 |
| KEY04 | 숫자 4 입력 |
| KEY05 | 숫자 5 입력 |
| KEY06 | 숫자 6 입력 |
| KEY07 | 숫자 7 입력 |
| KEY08 | 숫자 8 입력 |
| KEY09 | 입력 취소 (마지막 숫자 삭제) |
| KEY10 | 시작 / 다음 단계 |
| KEY11 | (미사용) |
| KEY12 | 입력 확정 |

### 게임 오버
- 생명이 0이 되면 게임 종료
- 하이스코어 경신 시 "NEW RECORD!" 메시지 표시
- KEY10으로 새 게임 시작 가능

## Vivado 프로젝트 생성

### 1. Vivado 프로젝트 생성
```tcl
create_project memory_game ./vivado_project -part xc7s75fggg484-1
```

### 2. 소스 파일 추가
```tcl
# Verilog 소스 파일 추가
add_files [glob ./src/*.v]

# 제약 파일 추가
add_files -fileset constrs_1 ./constraints/memory_game_constraints.xdc

# 최상위 모듈 설정
set_property top memory_game_top [current_fileset]
```

### 3. 합성 및 구현
```tcl
# 합성
launch_runs synth_1
wait_on_run synth_1

# 구현
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
```

### 4. 비트스트림 생성 및 프로그래밍
- 비트스트림 파일: `./vivado_project/memory_game.runs/impl_1/memory_game_top.bit`
- Vivado Hardware Manager로 FPGA 프로그래밍

## 모듈 설명

### memory_game_top.v
최상위 모듈로 모든 서브 모듈을 인스턴스화하고 연결합니다.

### fsm_controller.v
게임의 메인 상태 머신을 제어합니다.
- **상태**: POWER_OFF, IDLE, INIT, GEN_PATTERN, SHOW_PATTERN, GET_INPUT, COMPARE, CORRECT, WRONG, GAMEOVER
- 각 상태에 따른 제어 신호 생성

### lfsr_random.v
16비트 LFSR을 사용한 의사 난수 생성기로, 1~8 범위의 숫자를 생성합니다.

### led_player.v
패턴에 따라 LED를 순차적으로 제어하고 동기화된 오디오 신호를 생성합니다.

### debouncer.v
20ms 디바운스 시간을 사용하여 버튼 입력을 안정화합니다.

### input_buffer.v
사용자 입력을 저장하고 취소 기능을 제공합니다.

### pattern_compare.v
사용자 입력과 생성된 패턴을 비교하여 정답 여부를 판단합니다.

### highscore_reg.v
현재 세션의 최고 기록을 유지합니다.

### rgb_led_ctrl.v
정답/오답에 따라 RGB LED의 색상을 제어합니다 (초록색/빨간색).

### piezo_sound.v
PWM을 사용하여 다양한 음계를 생성합니다 (C4~C5: 262Hz~523Hz).

### lcd_controller.v
HD44780 호환 LCD를 제어하여 게임 정보를 표시합니다.

### seg_timer.v
단일 7-segment에 9~0 카운트다운을 표시합니다.

### seg_input_view.v
8-array 7-segment를 multiplexing하여 사용자 입력을 우측 정렬로 표시합니다.

## 타이밍 사양

- **시스템 클럭**: 100 MHz (10ns 주기)
- **LED 재생 속도**: 각 패턴당 500ms
- **사운드 지속 시간**: 300ms
- **타이머 카운트다운**: 1초 단위
- **RGB 피드백 시간**: 1초
- **7-segment 스캔 주파수**: ~1kHz

## 디버깅 팁

### 시뮬레이션
Vivado Simulator 또는 ModelSim을 사용하여 각 모듈을 개별적으로 테스트할 수 있습니다.

### 일반적인 문제
1. **버튼이 반응하지 않음**: 디바운서 설정 확인
2. **LCD에 아무것도 표시되지 않음**: 초기화 시퀀스 대기 (약 150ms)
3. **LED가 깜박임**: 패턴 재생 중 정상 동작
4. **소리가 나지 않음**: Piezo 연결 및 PWM 신호 확인

## 향후 개선 사항

- [ ] 난이도 선택 기능 (DIP 스위치 사용)
- [ ] 비휘발성 메모리를 사용한 영구 하이스코어 저장
- [ ] 다양한 게임 모드 (역순 입력, 시간 제한 단축 등)
- [ ] UART를 통한 외부 스코어보드 연동
- [ ] 더 복잡한 사운드 효과

## 라이선스

이 프로젝트는 교육 목적으로 제작되었습니다.

## 작성자

Logic Circuit Design Lab - Term Project

## 버전

- **v1.0.0** (2025-12-04): 초기 릴리스
  - 기본 게임 메커니즘 구현
  - 모든 하드웨어 인터페이스 통합
  - LCD, LED, Piezo, 7-segment 제어
  - 하이스코어 시스템
