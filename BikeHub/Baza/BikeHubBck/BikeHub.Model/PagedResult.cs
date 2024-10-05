using System;
using System.Collections.Generic;
using System.Text;

namespace BikeHub.Model
{
    public class PagedResult <T>
    {
        public int Count { get; set; }
        public List<T> ResultsList { get; set; }
    }
}
