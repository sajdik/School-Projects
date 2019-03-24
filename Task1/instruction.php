<?php

    //class instruction used to collect data about instructions and its arguments
    class Instruction{
        private $order = 0;
        private $opcode = "instr";
        private $args = array("none","none","none");
        private $argType = array("none","none","none");
        private $argCount = 0;

        // add argument to instruction
        public function addArg($type, $arg){
            $this->args[$this->argCount] = $arg;
            $this->argType[$this->argCount] = $type;
            $this->argCount++;
        }

        //print XML representation of instruction(+arguments) on stdout
        public function printXML(){
            echo "\t<instruction order=\"$this->order\" opcode=\"$this->opcode\">\n";
            for($i = 0; $i < $this->argCount; $i++){
                $index = $i + 1;
                echo "\t\t<arg$index type=\"{$this->argType[$i]}\">{$this->args[$i]}</arg$index>\n";
            }
            echo "\t</instruction>\n";
        }

        // initiate class instance with opcode(instruction name) 
        public function set($opcode){
            static $orderCounter = 0;
            $orderCounter++;
            $this->order = $orderCounter;
            $this->opcode = $opcode;
            $this->argCount = 0;
        }
    }
?>