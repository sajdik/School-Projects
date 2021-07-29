################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Sources/Coder.c \
../Sources/Keyboard.c \
../Sources/Queue.c \
../Sources/Speaker.c \
../Sources/main.c 

OBJS += \
./Sources/Coder.o \
./Sources/Keyboard.o \
./Sources/Queue.o \
./Sources/Speaker.o \
./Sources/main.o 

C_DEPS += \
./Sources/Coder.d \
./Sources/Keyboard.d \
./Sources/Queue.d \
./Sources/Speaker.d \
./Sources/main.d 


# Each subdirectory must supply rules for building sources it contributes
Sources/%.o: ../Sources/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross ARM C Compiler'
	arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g3 -I"../Sources" -I"../Includes" -std=c99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


