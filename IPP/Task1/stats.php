<?php

    // Stats class used to collect and print data about parsing
    class Stats{
        public $do = array();
        private $outputFile;
        private $lines = -1;
        private $comments = 0;
        private $labels = 0;
        private $jumps = 0;

        public function setOutputFile($fileName){
            $this->outputFile = $fileName;
        }

        public function addLine(){
            $this->lines++;
        }

        public function addComment(){
            $this->comments++;
        }

        public function addLabel(){
            $this->labels++;
        }

        public function addJump(){
            $this->jumps++;
        }

        // prints stats data into output file
        public function print(){
            if(!is_writable($this->outputFile) && file_exists($this->outputFile)){
                fwrite(STDERR, "File \"{$this->outputFile}\" cannot be openned!\n");
                exit(12);
            }
            $file = fopen($this->outputFile,"w");
            if($file == NULL){
            }
            for($i = 0; $i < count($this->do);$i++){
                switch($this->do[$i]){
                    case "lines": fwrite($file, "$this->lines\n"); break;
                    case "comments": fwrite($file, "$this->comments\n"); break;
                    case "jumps": fwrite($file, "$this->jumps\n"); break;
                    case "labels": fwrite($file, "$this->labels\n"); break;
                }
            }
            fclose($file);
        }
    }
?>