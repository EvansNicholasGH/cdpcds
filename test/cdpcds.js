const cdpcds = artifacts.require("cdpcds");
let instance;//holds the contract instance globaly
let a0, a1, a2, a3, a4;//account variables also global

//all testing is done here
//TEST 1
contract('Testing CDPCDS', async (accounts) => {

    //README:

    //it statmements define single test. should end with assertion/s. 
    //first one assigns deployed contract instance to 'instance' variable, and acounts to their respective variables.
    //it calls makeCDSOrder from acc1 with 10 ether as collateral.
    //the assert checks if the CDS was successfully created by checking for equality between acc1 and the first data point of getInfo ( the maker) for cds with ID 0.

    //FYI: for view functions (functions that return data and dont change the state of the blockchain)
    //use instance.XYZmethod.call(paramValue) instead of instance.XYZmethod(paramvalue)

    //USE AFTER DATA CALL TO PRINT DATA
    //console.log("Maker:           "+data[0]+"\n"+"MakerCollateral: "+data[1]+"\n"+"Taker:           "+data[2]+"\n"+"TakerCollateral: "+data[3]+"\n"+"Premium:         "+data[4]+"\n"+"Payed:           "+data[5]+"\n"+"ContractBalance: "+data[6]+"\n");
    //USE AFTER DATA CALL TO PRINT DATA

    //reminder: this is javascript so we can get very creative with our tests. loops, external file logs, dynamic variables you name it. 

    it("Should deploy new conract and create CDP", async () => {
        instance = await cdpcds.deployed();
        a0 =  accounts[0];
        a1 = accounts[1];
        a2 = accounts[2];
        a3 = accounts[3];
        a3 = accounts[4];
        await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
        let data;
        let strcheck;
        data = await instance.getInfo.call(0);
        assert.equal(a1,data[0]);
   
    });

    //fills the CPD, you know how it goes now. pretty simple
    it("Should fill CDP", async () => { 
        let data;
        let strcheck;
        await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
        data = await instance.getInfo.call(0);  
        assert.equal(a2,data[2]);
    });
    it("correct balance after requesting premium  #1", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1539154800);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct balance after requesting premium #2", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1539327600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct balance after requesting premium #3", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1539586800);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct balance after requesting premium #4", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1539759600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct balance after requesting premium #5", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1540278000);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct balance after requesting premium #6", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1540882800);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct balance after requesting premium #7", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1541487600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("Should create new CDP", async () => {
        instance = await cdpcds.deployed();
        await instance.makeCDSOrder(1000000000000000000,{from: a3, value: 10000000000000000000});
        let data;
        let strcheck;
        data = await instance.getInfo.call(1);
        assert.equal(a3,data[0]);       
    });
    it("Should fill CDP", async () => { 
        let data;
        let strcheck;
        await instance.fillCDSOrder(1,1539068400,{value:3000000000000000000,from: a4});
        data = await instance.getInfo.call(1);  
        assert.equal(a4,data[2]);
        });
    it("correct balance after requesting premium  #1", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(1,1539759600);    
        data = await instance.getInfo.call(1);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
})
//TEST 2
//deploy new contract.
contract('Testing CDPCDS', async (accounts) => {
    it("Should deploy new conract and create CDP", async () => {
        instance = await cdpcds.deployed();
        await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
        let data;
        let strcheck;
        data = await instance.getInfo.call(0);
        assert.equal(a1,data[0]);
   
    });
    it("Should fill CDP", async () => { 
        let data;
        let strcheck;
        await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
        data = await instance.getInfo.call(0);  
        assert.equal(a2,data[2]);
    });
    it("correct close outcome", async () => { 
        let data;
        let strcheck;
        await instance.close(0,1539759600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"no");
    });
})
    //TEST 3
    //new contract
contract('Testing CDPCDS', async (accounts) => {
    it("Should deploy new conract and create CDP", async () => {
        instance = await cdpcds.deployed();
        await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
        let data;
        let strcheck;
        data = await instance.getInfo.call(0);
        assert.equal(a1,data[0]);       
    });
    it("Should fill CDP", async () => { 
        let data;
        let strcheck;
        await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
        data = await instance.getInfo.call(0);  
        assert.equal(a2,data[2]);
        });
    it("correct balance after requesting premium  #1", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1539759600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct close outcome", async () => { 
        let data;
        let strcheck;
        await instance.close(0,1541487600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"no");
    });
})

    //TEST 4
    //new contract
contract('Testing CDPCDS', async (accounts) => {
    it("Should deploy new conract and create CDP", async () => {
        instance = await cdpcds.deployed();
        await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
        let data;
        let strcheck;
        data = await instance.getInfo.call(0);
        assert.equal(a1,data[0]);       
    });
    it("Should fill CDP", async () => { 
        let data;
        let strcheck;
        await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
        data = await instance.getInfo.call(0);  
        assert.equal(a2,data[2]);
        });
    it("correct balance after requesting premium  #1", async () => { 
        let data;
        let strcheck;
        await instance.requestPremium(0,1539759600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"2000000000000000000");
    });
    it("correct close outcome", async () => { 
        let data;
        let strcheck;
        await instance.close(0,1541487600);    
        data = await instance.getInfo.call(0);  
        strcheck = ""+data[3];
        assert.equal(strcheck,"no");
    });
})   
    

//test1

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539154800)  1
//requestPremium(0,1539327600)  2
//requestPremium(0,1539586800)  3
//requestPremium(0,1539759600)  4
//requestPremium(0,1540278000)  5
//requestPremium(0,1540882800)  6
//requestPremium(0,1541487600)  7
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a3})
//fillCDSOrder(1,1539068400,{val:3000000000000000000,from:a4})
//requestPremium(1,1539759600)
//close(1,1539759600,{from:a3})

//test2

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539759600)
//close(0,1539759600)

//test3 

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539759600)
//close(0,1541487600)

//test4 

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1541487600)
//close(0,1541487600)