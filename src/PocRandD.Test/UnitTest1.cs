using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Xunit;
using PocRandD.Controllers;
using Moq;

namespace PocRandD.Test
{
    public class UnitTest1
    {
        [Fact]
        public void Test1()
        {
            var mock = new Mock<ILogger<HomeController>>();
            var logger = mock.Object;
            var controller = new HomeController(logger);
            var result = controller.Privacy();
            Assert.NotNull(result);
        }
    }
}
