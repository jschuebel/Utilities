Knockout dump JSON viewmodel
<div data-bind="text: ko.toJSON($root)"></div>

--LINQ Dump sql
Namespace:  System.Data.Objects
Assembly:  System.Data.Entity (in System.Data.Entity.dll)
ObjectQuery<Product> productQuery =
        context.Products.Where("it.ProductID = @productID");
    productQuery.Parameters.Add(new ObjectParameter("productID", productID));

    // Write the store commands for the query.
    Console.WriteLine(productQuery.ToTraceString());

	
--LINQ compiled query
using System.Linq;
using System.Data.Entity;

using System.Data.Objects;


        private static readonly Func<personEntities, IQueryable<PersonState>> compiledGeneralQuery =
        CompiledQuery.Compile((personEntities context) => from g in context.Generals
                                                          join a in context.Addresses on g.Address_ID equals a.id
                                                          select new PersonState
                                                          {
                                                              id = g.id,
                                                              Address_ID = g.Address_ID,
                                                              Name = g.Name,
                                                              Address1 = a.Address1,
                                                              City = a.City,
                                                              State = a.State,
                                                              Zip = a.Zip
                                                          });


           using (personEntities t1 = new personEntities())
           {
               t1.Generals.MergeOption = MergeOption.NoTracking;
               var qry = compiledGeneralQuery(t1).ToList();
