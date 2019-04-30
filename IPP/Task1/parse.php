<?php

    include("stats.php");
    include("instruction.php");
    
    $stat = new Stats;
    $instr = new Instruction;
    $c;

    main($argc,$argv);

    // Main function - runs the program
    function main($argc,$argv){
        global $stat;
        $doStats = handleProgramArguments($argc, $argv);
        checkHeader();
        printXmlHeader();
        parse();
        printFoot();
        if($doStats) $stat->print();
    }
    

    // Function handle program arguments
    // returns true if extenstion stats is supposed to be used
    // else returns false
    // Program can be exited in case of --help argument 
    function handleProgramArguments($argc, $argv){
        if($argc > 1){
            if($argv[1] == "--help"){
                if($argc != 2){
                    error(10, "Unsuported argument combination\n");
                }
                printHelp();
                exit(0);
            }else{
                return handleStatArguments($argc,$argv);
            }       
        }
        return false;
    }

    // stat extension argument handler 
    // sets which stats should be saved
    // returns if stats should be made 
    function handleStatArguments($argc,$argv){
        global $stat;
        $doStats = false;
        $needStats = false;
        $output_array;
        for($i = 1;$i < $argc;$i++){
            if($argv[$i] == "--labels"){
                if(in_array("labels",$stat->do)) error(10, "Parse: STAT arguments error");
                array_push($stat->do, "labels");
                $needStats = true;
            }elseif($argv[$i] == "--loc"){
                if(in_array("lines",$stat->do)) error(10, "Parse: STAT arguments error");
                array_push($stat->do, "lines");
                $needStats = true;
            }elseif($argv[$i] == "--comments"){
                if(in_array("comments",$stat->do)) error(10, "Parse: STAT arguments error");
                array_push($stat->do, "comments");
                $needStats = true;
            }elseif($argv[$i] == "--jumps"){
                if(in_array("jumps",$stat->do)) error(10, "Parse: STAT arguments error");
                array_push($stat->do, "jumps");
                $needStats = true;
            }elseif(preg_match('/--stats=(.*)/', $argv[$i], $output_array)){
                $stat->setOutputFile($output_array[1]);
                $doStats = true;
            }else{
                error(10,"Parse: ERROR - using unknown argument: \"{$argv[$i]}\"\n");
            }
        }
        if(!$doStats && $needStats){
            error(10, "Parse: unsuported combination of arguments\n");
        }
        return $doStats;
    }


    // Exits program in case that header error 
    function checkHeader(){
        $word = readWord();
        while($word == "\n"){
            $word = readWord();
        }
        global $c;
        if(strtoupper($word) != ".IPPCODE19"){
            error(21,"Parse: Header error\n");
        }else{
            if($c == "\n"){
                return;
            }else{
                $word = readWord();
                if($word != "\n"){
                error(21,"Parse: Header error\n");
                }
            }
        }
    }

    // prints XML header on stdin
    function printXmlHeader(){
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<program language=\"IPPcode19\">\n";
    }

    // performs lexical and syntactical analysys 
    // while collecting informations about instructions and its arguments
    // and printing them on stdin as XML
    function parse(){
        global $c;
        $word = readWord();
        while($word){
            if(handleInstruction($word)){
                if($c == " "){
                    $word = readWord();
                    if($word != "\n"){
                        error(23, "Parse: Expected EOL instead got \"$word\"\n");
                    }
                }elseif($c == "\n"){
                    $word = readWord();
                }else{
                    error(23, "Parse: Never should happen\n");
                }
            }
            else{
                error(22, "Parse: $word is not instruction!\n");
            }
        }
    }

    // print XML foot of output XMLfile
    function printFoot(){
        echo "</program>\n";
    }

    // handle instruction and all of its arguments
    // returns false in case of instruction error
    function handleInstruction($word){
        if($word == "\n"){
            return true;
        }
        global $instr, $stat;
        $instr->set($word);
        switch (strtoupper($word)){
            case "CREATEFRAME":
            case "PUSHFRAME":
            case "POPFRAME":
            case "RETURN": 
            case "BREAK":
                break;         
            case "DEFVAR":
            case "POPS":
                expectVar(); break;
            case "PUSHS":
            case "WRITE":
            case "EXIT";
            case "DPRINT":
                expectSymb(); break;
            case "CALL":
                expectLabel(); break;     
            case "LABEL":
                $stat->addLabel();
                expectLabel(); break;     
            case "JUMP":
                $stat->addJump();
                expectLabel(); break;     
            case "MOVE":
                expectVar(); expectSymb(); break;
            case "READ":
                expectVar(); expectType(); break;
                break;
            case "ADD":
            case "SUB":
            case "MUL":
            case "IDIV":
            case "LT":
            case "GT":
            case "EQ": 
            case "AND":
            case "OR":
            case "STRI2INT":
            case "CONCAT":
            case "GETCHAR":
            case "SETCHAR":
                expectVar(); expectSymb(); expectSymb(); break;
            case "NOT":
                expectVar(); expectSymb(); break;
            case "INT2CHAR":
            case "STRLEN":
            case "TYPE":
                expectVar(); expectSymb(); break;            
            case "JUMPIFEQ":
            case "JUMPIFNEQ":
                $stat->addJump();
                expectLabel(); expectSymb(); expectSymb(); break;
            default: return false;
        }
        $instr->printXML();
        return true;
    }
    
    // check if next word on stdin is argument of var type
    function expectVar(){
        $word = readWord();
        if(!isVar($word)){
            error(23,"Parse: not a var: $word\n");
        }
        global $instr;
        $word = replaceWPFspecials($word);
        $instr->addArg("var",$word);
    }

    // checks if next word on stdin is argument of one of the symb types
    function expectSymb(){
        global $instr;
        $word = readWord();
        if(isint($word)){
            $instr->addArg("int",cutType($word));
        }elseif(isString($word)){
            $word = replaceWPFspecials($word);
            $instr->addArg("string",cutType($word));
        }elseif(isBool($word)){
            $instr->addArg("bool",cutType($word));
        }elseif(isNil($word)){
            $instr->addArg("nil",cutType($word));
        }elseif(isVar($word)){
            $word = replaceWPFspecials($word);
            $instr->addArg("var",$word);
        }else{
            error(23,"Parse: Not a symbol: $word\n");
        }
    }

    //cut type part from symb argument
    //return word without type part
    function cutType($word){
        $output_array;
        preg_match('/@(.*)\z/', $word, $output_array);
        return $output_array[1];

    }

    //returns if word is var
    function isVar($word){
        $output_array;
        return preg_match('/\A[TGL]F@[a-zA-Z_!\?%$\-&\*][a-zA-Z_!\?%$\-&\d\*]*\z/', $word, $output_array);
    }

    //returns if word is int
    function isInt($word){
        $output_array;
        return preg_match('/\Aint@[+-]?\d+\z/', $word, $output_array);
    }

    //returns if word is string
    function isString($word){
        $output_array;
        if(preg_match('/\Astring@[^#\s]*\z/', $word, $output_array)){
            return backslashCheck($word);
        }else{
            return false;
        }
    }

    //returns if word is bool
    function isBool($word){
        $output_array;
        return preg_match('/\Abool@true\z|\Abool@false\z/', $word, $output_array);
    }
    
    //returns is word is nil
    function isNil($word){
        $output_array;
        return preg_match('/\Anil@nil\z/', $word, $output_array);
    }

    //checks backslashes in word
    //return true if all backslashes are folowed with 3 numbers
    function backslashCheck($word){
        $expectNums = 0;
        $nums = array("0","1","2","3","4","5","6","7","8","9");
        for($i = 0; $i < strlen($word); $i++){
            if($expectNums != 0){
                if(in_array($word[$i],$nums)){
                    $expectNums--;
                }else{
                    return false;
                }
            }
            elseif($word[$i] == "\\"){
                $expectNums = 3;
            }
        }
        return $expectNums == 0;
    }

    //converting WPF special symbols
    function replaceWPFspecials($word){
        $word = preg_replace('/&/', '&amp;', $word);
        $word = preg_replace('/</', '&lt;', $word);
        $word = preg_replace('/>/', '&gt;', $word);
        $word = preg_replace('/\"/', '&quot;', $word);
        $word = preg_replace('/\'/', '&apos;', $word);
        return $word;
    }

    //checks if next word on stdin is label
    function expectLabel(){
        global $instr;
        $word = readWord();
        if(!isLabel($word)){
            error(23,"Parse: Not a label: $word\n");
        }
        $instr->addArg("label",$word);
    }

    //returns if word is label
    function isLabel($word){
        $output_array;
        return preg_match('/\A[a-zA-Z_!?%$\-&][a-zA-Z_!?%$\-&\d]*\z/', $word, $output_array);
    }

    //checks if next word on stdin is type
    function expectType(){
        global $instr;
        $word = readWord();
        if(!isType($word)){
            error(23,"Parse: Not a type: $word\n");
        }
        $instr->addArg("type",$word);
    }

    // returns of word is type
    function isType($word){
        return $word == "int" || $word == "bool" || $word == "string";
    }

    // load string from stdin ignoring all whitespace and comments
    function readWord(){
        static $isNewLine = true;
        $word = "";
        global $c, $stat;      
        $c = getchar();
        if($c == "\n"){
            return "\n";
        }
        if($c == " " || $c == "\t") {
            $word = ignoreWhiteSpace();
        }
        if ($c == '#'){
            ignoreComment();
            $stat->addComment();
            if(!$isNewLine){
                $stat->addLine();
                $isNewLine = true;
            }
            return "\n";
        }
        $isNewLine = false;
        if($c == " " || $c == "\t") {
            $word = ignoreWhiteSpace();
        }
        while($c != "\n" && $c != ' ' && $c != '\t' && $c != "#" &&!feof(STDIN)){
            $word .= $c;
            $c = getchar();
        }
        if(!$c){
            return false;
        }
        if($c == "#"){  
            $stat->addComment();            
            ignoreComment();
            $isNewLine = true;
        }
        if($c == "\n"){
            $isNewLine = true;
            $stat->addLine();
        }
        return $word;
    }

    // loading from stdin while white-space 
    function ignoreWhiteSpace(){
        global $c;
        while($c == " " || $c == "\t"){
            $c = getchar();
        }
        if($c == "\n"){
            return "\n";
        }
    }

    // loading from stdin till comment end
    function ignoreComment(){
        global $c;
        $c = getchar();
        while($c != "\n" && !feof(STDIN)){
            $c = getchar();
        }
    }

    // loads one char from stdin
    function getchar(){
        return fread(STDIN,1);
    }

    // prints help (used in --help argument)
    function printHelp(){
        echo "Skript typu filtr nacte ze standartniho vstupu zdrojovy kod v IPPcode19!\n";
        echo "zkontroluje lexikalni a syntaktickou spravnost kodu a vypise na standartni vystup XML reprezentaci programu.\n";
    }

    // function prints error message( errMessage) on stderr 
    // and exits program with error code (errCode)
    function error($errCode, $errMessage){
        fwrite(STDERR, $errMessage);
        exit($errCode);
    }

    return 0;
?>
