// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MySBT.sol"; // 替换为你的合约路径

contract MySBTTest is Test {
    MySBT sbt;

    // 模拟的地址
    address public OWNER = makeAddr("owner");
    address public RECIPIENT = makeAddr("recipient");
    
    // 假设你的 SBT ID
    uint256 public CONST_SBT_ID = 1001;

    function setUp() public {
        // 设置执行环境
        vm.prank(OWNER); 
        // 1. 部署你的合约
        sbt = new MySBT(/* 构造函数参数 */);
    }

    function testSimulateFailingMint() public {
        // 模拟前端交易失败的场景
        
        // --- 模拟导致回滚的条件（例如：尝试用非授权地址铸造） ---
        address unauthorized = makeAddr("unauthorized");
        vm.prank(unauthorized); 
        
        // 1. 期望的回滚信息（如果你知道的话）
        // 如果你知道回滚信息是 "Caller not authorized"，你可以这样写：
        // vm.expectRevert("Caller not authorized"); 
        
        // 如果你不确定，你可以使用 expectRevert() 不带参数来捕获任何回滚：
        vm.expectRevert(); 
        
        // 2. 模拟交易调用
        sbt.mint(
            RECIPIENT, 
            CONST_SBT_ID
        );
        
        // 如果代码到达这里，说明交易没有回滚（测试失败）
    }
    
    // 💡 进阶：如果你想捕获 Out-of-Gas 错误
    function testSimulateOutOfGas() public {
        // 3. 使用 gasLimit 限制来模拟 Out-of-Gas
        // 假设你想要模拟一个Gas Limit为100000的交易
        vm.startPrank(OWNER);
        vm.expectRevert("Transaction ran out of gas");
        vm.gasLimit(100000); // 设置一个极低的Gas Limit
        
        sbt.mint(RECIPIENT, CONST_SBT_ID); 
    }
}