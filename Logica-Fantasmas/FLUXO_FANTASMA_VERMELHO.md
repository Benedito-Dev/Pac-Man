# LÓGICA DO FANTASMA VERMELHO - FLUXO ORGANIZADO

## 🎯 **CONCEITO BÁSICO**
O fantasma é como um **robô com 5 programas diferentes**. Ele só pode executar **1 programa por vez**, e muda de programa baseado em **eventos** e **timers**.

---

## 📋 **FLUXO PRINCIPAL - PASSO A PASSO**

### **PASSO 1: NASCIMENTO** 
```
🎮 Jogo inicia
↓
👻 Fantasma aparece na posição inicial
↓  
🧭 Sistema de navegação é configurado
↓
⚡ Vai para PASSO 2
```

### **PASSO 2: PATRULHA (8 segundos)**
```
🚶 ESTADO: SCATTER
↓
📍 Vai para ponto Red1 (-180, -217)
↓
✅ Chegou? → Vai para Red2 (-300, -217)  
↓
✅ Chegou? → Vai para Red3 (-300, -312)
↓
✅ Chegou? → Vai para Red4 (-180, -313)
↓
✅ Chegou? → Volta para Red1 (LOOP)
↓
⏰ Timer de 8 segundos acabou? → Vai para PASSO 3
```

### **PASSO 3: PERSEGUIÇÃO (até algo acontecer)**
```
🎯 ESTADO: CHASE  
↓
📍 Mira no Pacman
↓
🏃 Vai direto atrás do Pacman
↓
🔄 Atualiza posição do Pacman constantemente
↓
❓ O que acontece?
   ├─ 💊 Pacman comeu power pellet? → Vai para PASSO 4
   ├─ 👻 Tocou no Pacman? → Pacman morre, volta PASSO 2  
   └─ 🔄 Nada? → Continua perseguindo
```

### **PASSO 4: FUGA (tempo limitado)**
```
😱 ESTADO: RUN_AWAY
↓
🔵 Fica azul e sem olhos
↓
🎲 Escolhe posição aleatória no mapa
↓
🏃💨 Foge para lá
↓
❓ O que acontece?
   ├─ 🍽️ Pacman me comeu? → Vai para PASSO 5
   ├─ ⏰ Tempo de fuga acabou? → Volta PASSO 3
   └─ 🔄 Nada? → Continua fugindo
```

### **PASSO 5: MORTE (volta pra casa)**
```
💀 ESTADO: EATEN
↓
👁️ Só sobram os olhos
↓
🏠 Vai direto para casa
↓
✅ Chegou em casa? → Volta PASSO 3
```

---

## 🎮 **EXEMPLO PRÁTICO - PRIMEIRO MINUTO DE JOGO**

```
⏰ 0:00 - Jogo inicia
👻 Fantasma aparece em (0, -72)
📍 Vai para Red1 (-180, -217)

⏰ 0:03 - Chegou em Red1  
📍 Vai para Red2 (-300, -217)

⏰ 0:05 - Chegou em Red2
📍 Vai para Red3 (-300, -312)

⏰ 0:08 - Timer de 8 segundos acabou!
🎯 MUDA PARA PERSEGUIÇÃO
📍 Vai direto atrás do Pacman

⏰ 0:15 - Pacman comeu power pellet!
😱 MUDA PARA FUGA
🔵 Fica azul
📍 Vai para posição aleatória

⏰ 0:25 - Pacman comeu o fantasma!
💀 MUDA PARA MORTE  
👁️ Só olhos
📍 Volta para casa

⏰ 0:30 - Chegou em casa
🎯 MUDA PARA PERSEGUIÇÃO
📍 Vai atrás do Pacman novamente
```

---

## 🧠 **RESUMO MENTAL**

**Pense assim:**
1. Fantasma = Robô com 5 programas
2. Só roda 1 programa por vez  
3. Muda de programa por eventos (timer, colisão, etc)
4. Cada programa tem um comportamento específico
5. GPS (NavigationAgent2D) cuida do movimento
6. Você só precisa dizer "vá para X" e ele vai

**A mágica está em:**
- Saber QUANDO mudar de programa
- Saber PARA ONDE ir em cada programa
- Deixar o Godot cuidar do movimento

---

## 🔧 **ESTADOS DO FANTASMA**

| Estado | Comportamento | Duração | Próximo Estado |
|--------|---------------|---------|----------------|
| SCATTER | Patrulha entre 4 pontos | 8 segundos | CHASE |
| CHASE | Persegue Pacman | Indefinido | RUN_AWAY ou SCATTER |
| RUN_AWAY | Foge do Pacman | Timer variável | CHASE ou EATEN |
| EATEN | Volta para casa | Até chegar | CHASE |
| STARTING_AT_HOME | Fica na base | Timer | SCATTER |

---

## 📍 **PONTOS DE PATRULHA DO FANTASMA VERMELHO**

- **Red1**: (-180, -217) - Canto superior esquerdo
- **Red2**: (-300, -217) - Mais à esquerda  
- **Red3**: (-300, -312) - Canto superior esquerdo extremo
- **Red4**: (-180, -313) - Volta pro início

**Sequência**: Red1 → Red2 → Red3 → Red4 → Red1 (LOOP)