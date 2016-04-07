object VeryBigSum {
  def main(args: Array[String]): Unit = {
    val sc = new java.util.Scanner(System.in)
    val n = sc.nextInt()
    var ints = new Array[BigInt](n)
    for (i <- 0 to n-1) {
      ints(i) = BigInt(sc.nextInt())
    }
    println(ints.sum)
  }
}
