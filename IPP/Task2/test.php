<?php
    /*
        Structure used to store info about settings of this script
    */
    class TestInfo{
        public $Dir = ".";
        public $RecursiveSearch = false;
        public $ParseScript = "parse.php";
        public $IntScript = "interpret.py";
        public $ToTest = "all";
    }

    /*
        Structure used to store info about test result
    */
    class TestResult{
        public $Name = "Unknown";
        public $Passed = false;
        public $Rc = 0;
        public $ExpectRc = 0;
        public $OutputFailed = false;
    }
    
    $testInfo = handleProgramArguments($argc,$argv);
    $testList = getTestList($testInfo->Dir, $testInfo->RecursiveSearch);
    $testList = removeEmptyDirsFromMat($testList);    
    generateMissingTestFiles($testList);
    $results = executeTests($testList); 
    printResults($results);
    deleteFiles();

    /*
        Function takes care of program arguments
        returns TestInfo object
    */
    function handleProgramArguments($argc,$argv){
        if($argc == 1) return new TestInfo;
        if($argv[1] == "--help"){
            if($argc != 2){
                exit(10);
            }
            printHelp();
            exit(0);
        }
        $testInfo = new TestInfo;
        $output_array;
        for($i = 1; $i < $argc; $i++){
            if(preg_match('/--directory=(.+)/', $argv[$i], $output_array)){
                $testInfo->Dir = $output_array[1];
            }
            elseif($argv[$i] == "--recursive"){
                $testInfo->RecursiveSearch = true;
            }
            elseif(preg_match('/--parse-script=(.+)/', $argv[$i], $output_array)){
                $testInfo->ParseScript = $output_array[1];
            }
            elseif(preg_match('/--int-script=(.+)/', $argv[$i], $output_array)){
                $testInfo->IntScript = $output_array[1];                
            }
            elseif($argv[$i] == "--parse-only" && $testInfo->ToTest == "all"){
                $testInfo->ToTest = "parse-only";
            }
            elseif($argv[$i] == "--int-only" && $testInfo->ToTest == "all"){
                $testInfo->ToTest = "int-only";
            }
            else{
                fwrite(STDERR, "Wrong arguments\n");
                exit(10);
            }
        }
        return $testInfo;
    }

    /*
        Function searches for tests
        returns test in array
    */
    function getTestList($dir,$recursive){
        if(!is_dir($dir)){
            fwrite(STDERR, "Cannot open: \"$dir\"\n");
            exit(11);
        }
        if($recursive){
            $testList = recursiveSearch($dir);
        }else{
            $fileList = scandir($dir);
            $tests = findSrcFiles($fileList);
            $testList = array($dir => $tests);
        }
        return $testList;
    }

    /*
        Function search for .src files in file array
        returns found .src files in array without .src suffix
    */
    function findSrcFiles($fileList){
        $srcFiles = array();
        foreach($fileList as $file){
            $output_array;
            if(preg_match('/([^\/]+).src/', $file, $output_array)){
                array_push($srcFiles, $output_array[1]);
            }
        }
        return $srcFiles;
    }

    /*
        Recursive search for test 
        returns found test in array 
    */
    function recursiveSearch($dir){
        $list = scandir($dir);
        $testList = findSrcFiles($list);
        $testMat = array($dir => $testList); 
        foreach($list as $item){
            if(is_dir($dir."/".$item) &&  $item != "." && $item != ".."){
                $testMat = array_merge($testMat, recursiveSearch($dir."/".$item));
            }
        } 
        return $testMat;
    }

    /*
        Function generates missing files in for tests inserted in testList
    */
    function generateMissingTestFiles($testList){
        $keys = array_keys($testList);
        foreach($keys as $key){
            foreach($testList[$key] as $test){
                $name = createFullPath($test,$key);
                generateFiles($name);
            }
        }
    }

    /*
        Function returns string with joind test file with dir path
    */
    function createFullPath($test,$dir){
        return $dir."/".$test;
    }

    /*
        Function generates missing test files for test
    */ 
    function generateFiles($name){
        if(!file_exists($name.".in")){
            $file = fopen($name.".in","w");
            fclose($file);
        }
        if(!file_exists($name.".out")){
            $file = fopen($name.".out","w");
            fclose($file);
        }
        if(!file_exists($name.".rc")){
            $file = fopen($name.".rc","w");
            fwrite($file,"0\n");
            fclose($file);
        }
    }

    /*
        Function returnes matrix of files without empty directories
    */
    function removeEmptyDirsFromMat($mat){
        $keyList = array_keys($mat);
        $filteredMat = array();
        foreach($keyList as $key){
            if($mat[$key] != array()){
                $filteredMat[$key] = $mat[$key];
            }
        }
        return $filteredMat;
    }

    /*
        Function runs test directories
        returns array of TestResults
    */
    function executeTests($testList){
        $dirs = array_keys($testList);
        $results = array();
        foreach($dirs as $dir){
            $results = array_merge($results, executeTestDir($dir, $testList[$dir]));
        }
        return $results;
    }

    /*
        Function runs tests in directory
        returns array of TestResults
    */
    function executeTestDir($dirName, $dir){
        $results = array();
        foreach($dir as $test){
            array_push($results ,executeTest($dirName."/".$test));
        }
        return $results;
    }
    
    /*
        Function runs test
        returns TestResult
    */
    function executeTest($test){
        global $testInfo;
        if($testInfo->ToTest == "parse-only"){
            return parseOnlyTest($test, $testInfo->ParseScript);
        }
        elseif($testInfo->ToTest == "int-only"){
            return intOnlyTest($test, $testInfo->IntScript);
        }else{
            return bothTest($test, $testInfo->ParseScript, $testInfo->IntScript);
        }
    }

    /*
        Function runs parse only test
        returns TestResult 
    */ 
    function parseOnlyTest($test, $parseScript){
        $PHPint = "php7.3";
        $testResult = new TestResult;
        $retVal;
        $output_array;
        exec("$PHPint $parseScript<$test.src>test_script.xml 2>/dev/null",$output_array, $retVal);
        $testResult->Name = $test;
        $testResult->Rc = $retVal;
        $testResult->ExpectRC = getRetVal($test);

        if($retVal != $testResult->ExpectRC){}
        elseif(!cmpXML("$test.out", "test_script.xml") && $retVal == 0){
            $testResult->OutputFailed = true;
        }
        else{
            $testResult->Passed = true;
        }
        return $testResult;
    }

    /*
        Function runs int only test
        returns TestResult  
    */
    function intOnlyTest($test, $intScript){
        $PythonInt = "python3";
        $testResult = new TestResult;
        $retVal;
        $output_array;
        exec("$PythonInt $intScript --source=$test.src --input=$test.in>test_script.out 2>/dev/null", $output_array, $retVal);
        $testResult->Name = $test;
        $testResult->Rc = $retVal;
        $testResult->ExpectRC = getRetVal($test);

        if($retVal != $testResult->ExpectRC){}
        elseif(!cmpFiles("$test.out", "test_script.out") && $retVal == 0){
            $testResult->OutputFailed = true;
        }
        else{
            $testResult->Passed = true;
        }
        return $testResult;
    }

    /*
        Function runs test for both scripts
        returns TestResult  
    */
    function bothTest($test, $parseScript, $intScript){
        $testResult = new TestResult;
        $retVal;
        $output_array;
        $PHPint = "php7.3";
        $PythonInt = "python3";
        exec("$PHPint $parseScript<$test.src>test_script.xml 2>/dev/null",$output_array, $retVal);
        if($retVal == 0){
            exec("$PythonInt $intScript --source=test_script.xml --input=$test.in>test_script.out 2>/dev/null", $output_array, $retVal);
        }

        $testResult->Name = $test;
        $testResult->Rc = $retVal;
        $testResult->ExpectRC = getRetVal($test);

        if($retVal != $testResult->ExpectRC){}
        elseif(!cmpFiles("$test.out", "test_script.out") && $retVal == 0){
            $testResult->OutputFailed = true;
        }
        else{
            $testResult->Passed = true;
        }
        
        return $testResult;
    }

    /*
        Function loads value from .rc file and returns it
    */
    function getRetVal($test){
        $file = fopen($test.".rc", "r");
        $retVal = fread($file, 2);
        fclose($file);
        return $retVal;
    }

    /*
        Function compers 2 files using diff tool
        returns whether files equals
    */
    function cmpFiles($expectedOutFile, $outputFile){
        $output_array;
        $retVal = false;
        exec("diff -q $expectedOutFile $outputFile", $output_array, $retVal);
        return $retVal == 0;
    }

    /*
        Function compers 2 XML files using jexamxml tool
        returns whether files equal s
    */
    function cmpXML($expectedOutFile, $outputFile){
        $output_array;
        $retVal = false;
        exec("java -jar /pub/courses/ipp/jexamxml/jexamxml.jar $expectedOutFile $outputFile delta.xml /pub/courses/ipp/jexamxml/options", $output_array, $retVal);
        return $retVal == 0;
    }

    /*
        Function print results on stdout in html format  
    */
    function printResults($results){
        $passedCount = 0;
        $failedCount = 0;
        foreach($results as $result){
            if($result->Passed)
                $passedCount++;
            else{
                $failedCount++;
            }
        }
        echo "<!DOCTYPE html><html><head><title>Test results</title></head>
        <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td{align-content: middle}</style>
        <body><h1 align=\"center\">TEST RESULTS</h1>
        <h2 style=\"color:green\" align=\"center\"><b>PASSED: $passedCount</b></h2>
        <h2 style=\"color:red\" align=\"center\"><b>FAILED: $failedCount</b></h2>
        <table style=\"width:80%\" align=\"center\">
        <tr><th>Test</th><th>Result</th> <th>Reason</th></tr>";
        foreach($results as $result){
            printResult($result);
        }
        echo "</table></body></html>";
    }

    /*
        Prints table row with test result in html format
    */
    function printResult($result){
        $name = $result->Name;
        if($result->Passed){
            $res = "PASSED";
            $resultcolor = "green";
            $reason = "-";

        }else{
            $res = "FAILED";
            $resultcolor = "red";
            if($result->OutputFailed){
                $reason = "Outputs do not match";
            }else{
                $reason = "Expected: {$result->ExpectRc} but instead got: {$result->Rc}";
            }
        }
        echo "<tr><td>$name</td><td style=\"color:$resultcolor\">$res</td> <td>$reason</td></tr>\n";
    }

    /*
        Function delete temporary files used during testing
    */
    function deleteFiles(){
        if (file_exists("test_script.xml")){
            unlink("test_script.xml");
        }
        if(file_exists("test_script.out")){
            unlink("test_script.out");
        }
    }

    /*
        Function prints help on stdout
     */
    function printHelp(){
        echo "Script for automatical testing parse.php and interpret.py.";
        echo "Script takes tests from directory and prints html representation";
        echo "of results on stdout\n";
        echo "Usage: php7.3 test.php <arguments>\n";
        echo "List of arguments:\n";
        echo "--help, --directory=path, --recursive, --parse-script=file,";
        echo "--int-script=file,--parse-only, --int-only\n";
    }
?>

