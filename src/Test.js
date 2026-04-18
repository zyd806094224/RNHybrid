function main() {

  console.log('111111');
  let values = [2,3,2,7,5]
  let weight = [10,23,12,4,6]
  const res = bg(values,weight,25);
  console.log(res)
}

function bg(values, weight, W){
  let dp = []
  for(let j = 0;j<= W;j++){
    dp[j] = new Array(weight.length).fill(0)
  }

  //j 每一列代表背包的使用重量（空间） 从0 每次重量+1 递增 一直到 W 重量
  //i 每一行代表前i个 货物（物品）
  // dp[i][j]的值 就代表 前i个物品，背包重量为j的最大价值是多少
  for(let j = 0;j <= W;j++){
    dp[0][j] = (j >= weight[0]) ? values[0] : 0
  }

  for(let i = 1;i < weight.length;i++){
    for(let j = 0;j <= W;j++){
      if(weight[i] > j){
        dp[i][j] = dp[i - 1][j]
      }else{
        dp[i][j] = Math.max(dp[i - 1][j],values[i] + dp[i - 1][j - weight[i]])
      }
    }
  }

  return dp[weight.length - 1][W]




}


main();
