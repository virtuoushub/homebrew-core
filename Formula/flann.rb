class Flann < Formula
  desc "Fast Library for Approximate Nearest Neighbors"
  homepage "https://www.cs.ubc.ca/research/flann/"
  url "https://github.com/mariusmuja/flann/archive/1.9.1.tar.gz"
  sha256 "b23b5f4e71139faa3bcb39e6bbcc76967fbaf308c4ee9d4f5bfbeceaa76cc5d3"
  revision 6

  bottle do
    cellar :any
    sha256 "d63b6b851376c199e86938129b34616500be62354904b586e367af6108541609" => :mojave
    sha256 "dc63d79be691c9b18d98b8c900fc5eb6d824feb2d4e2a8b7e5fd085827f70cfb" => :high_sierra
    sha256 "9c825c76c662f0743adad10544fd7572a6d2449a59cc92da674da244ea2e209b" => :sierra
    sha256 "f6bf7096372eb9dc52ddb3fee2cceef07de63281777917005092ee88a7490b45" => :x86_64_linux
  end

  deprecated_option "with-python" => "with-python@2"

  depends_on "cmake" => :build
  depends_on "hdf5"
  depends_on "python@2" => :optional
  depends_on "numpy" if build.with? "python@2"

  # Fix for Linux build: https://bugs.gentoo.org/652594
  # Not yet fixed upstream: https://github.com/mariusmuja/flann/issues/369
  patch do
    url "https://raw.githubusercontent.com/buildroot/buildroot/0c469478f64d0ddaf72c0622a1830d855306d51c/package/flann/0001-src-cpp-fix-cmake-3.11-build.patch"
    sha256 "aa181d0731d4e9a266f7fcaf5423e7a6b783f400cc040a3ef0fef77930ecf680"
  end unless OS.mac?

  resource("dataset.dat") do
    url "https://www.cs.ubc.ca/research/flann/uploads/FLANN/datasets/dataset.dat"
    sha256 "dcbf0268a7ff9acd7c3972623e9da722a8788f5e474ae478b888c255ff73d981"
  end

  resource("testset.dat") do
    url "https://www.cs.ubc.ca/research/flann/uploads/FLANN/datasets/testset.dat"
    sha256 "d9ff91195bf2ad8ced78842fa138b3cd4e226d714edbb4cb776369af04dda81b"
  end

  resource("dataset.hdf5") do
    url "https://www.cs.ubc.ca/research/flann/uploads/FLANN/datasets/dataset.hdf5"
    sha256 "64ae599f3182a44806f611fdb3c77f837705fcaef96321fb613190a6eabb4860"
  end

  def install
    if build.with? "python@2"
      pyarg = "-DBUILD_PYTHON_BINDINGS:BOOL=ON"
    else
      pyarg = "-DBUILD_PYTHON_BINDINGS:BOOL=OFF"
    end

    system "cmake", ".", *std_cmake_args, pyarg
    system "make", "install"
  end

  test do
    resource("dataset.dat").stage testpath
    resource("testset.dat").stage testpath
    resource("dataset.hdf5").stage testpath
    system "#{bin}/flann_example_c"
    system "#{bin}/flann_example_cpp"
  end
end
