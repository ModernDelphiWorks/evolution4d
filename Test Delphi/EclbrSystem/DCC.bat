@echo off
CodeCoverage.exe ^
  -m PTestDictionary.map ^
  -e PTestDictionary.exe ^
  -dproj PTestDictionary.dproj ^
  -od CodeCoverage/Dictionary ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v

CodeCoverage.exe ^
  -m PTestMatch.map ^
  -e PTestMatch.exe ^
  -dproj PTestMatch.dproj ^
  -od CodeCoverage/Match ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
 
CodeCoverage.exe ^
  -m PTestTuple.map ^
  -e PTestTuple.exe ^
  -dproj PTestTuple.dproj ^
  -od CodeCoverage/Tuple ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestVector.map ^
  -e PTestVector.exe ^
  -dproj PTestVector.dproj ^
  -od CodeCoverage/Vector ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestMap.map ^
  -e PTestMap.exe ^
  -dproj PTestMap.dproj ^
  -od CodeCoverage/Map ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestList.map ^
  -e PTestList.exe ^
  -dproj PTestList.dproj ^
  -od CodeCoverage/List ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestStream.map ^
  -e PTestStream.exe ^
  -dproj PTestStream.dproj ^
  -od CodeCoverage/Stream ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestDirectory.map ^
  -e PTestDirectory.exe ^
  -dproj PTestDirectory.dproj ^
  -od CodeCoverage/Directory ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestObjects.map ^
  -e PTestObjects.exe ^
  -dproj PTestObjects.dproj ^
  -od CodeCoverage/Objects ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestThreading.map ^
  -e PTestThreading.exe ^
  -dproj PTestThreading.dproj ^
  -od CodeCoverage/Threading ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestStd.map ^
  -e PTestStd.exe ^
  -dproj PTestStd.dproj ^
  -od CodeCoverage/Std ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestStr.map ^
  -e PTestStr.exe ^
  -dproj PTestStr.dproj ^
  -od CodeCoverage/Str ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
CodeCoverage.exe ^
  -m PTestSafeTry.map ^
  -e PTestSafeTry.exe ^
  -dproj PTestSafeTry.dproj ^
  -od CodeCoverage/SafeTry ^
  -emma ^
  -xml ^
  -html ^
  -xmllines ^
  -v
  
timeout /t -1