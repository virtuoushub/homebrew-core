class Sundials < Formula
  desc "Nonlinear and differential/algebraic equations solver"
  homepage "https://computation.llnl.gov/casc/sundials/main.html"
  url "https://computation.llnl.gov/projects/sundials/download/sundials-3.2.0.tar.gz"
  sha256 "d2b690afecadf8b5a048bb27ab341de591d714605b98d3518985dfc2250e93f9"

  bottle do
    cellar :any
    sha256 "2b7b49fbbd44b8f4ed742f55fb56ee222617b902501723feb7b400657d99ba18" => :mojave
    sha256 "b7e15f2870901a6ba9259377e2551a320eae9c7ab29c2826f2291f37dd7748cc" => :high_sierra
    sha256 "e7881dfcfcf6d4ca5b405954107f63d128e8d08252dd53641e7455183b880c7c" => :sierra
    sha256 "6fe800637bad44e8e514c1ba852ee5d6608e26788ff3149a78e9d7619a506370" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "gcc" # for gfortran
  depends_on "open-mpi"
  depends_on "suite-sparse"
  depends_on "veclibfort" if OS.mac?
  depends_on "python" unless OS.mac?

  def install
    blas = "-L#{Formula["veclibfort"].opt_lib} -lvecLibFort"
    args = std_cmake_args + %W[
      -DCMAKE_C_COMPILER=#{ENV["CC"]}
      -DBUILD_SHARED_LIBS=ON
      -DKLU_ENABLE=ON
      -DKLU_LIBRARY_DIR=#{Formula["suite-sparse"].opt_lib}
      -DKLU_INCLUDE_DIR=#{Formula["suite-sparse"].opt_include}
      -DLAPACK_ENABLE=ON
      -DLAPACK_LIBRARIES=#{blas};#{blas}
      -DMPI_ENABLE=ON
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    cp Dir[prefix/"examples/nvector/serial/*"], testpath
    args = %w[
      -I#{include}
      test_nvector.c
      sundials_nvector.c
      test_nvector_serial.c
      -L#{lib}
      -lsundials_nvecserial
    ]
    args << "-lm" if OS.linux?
    system ENV.cc, *args
    assert_match "SUCCESS: NVector module passed all tests",
                 shell_output("./a.out 42 0")
  end
end
