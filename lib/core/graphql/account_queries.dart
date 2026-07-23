// GraphQL queries for Account Dashboard
// APIs: Customer Profile, Customer Addresses, Product Reviews
//
// Note: Orders and Wishlist queries are NOT available in the
// Bagisto demo storefront GraphQL schema. The dashboard gracefully
// shows empty states for those sections.

class AccountQueries {
  /// Get customer profile
  /// Actual API query: accountInfo
  /// Returns: Customer type
  static const String getCustomerProfile = r'''
    query getCustomerProfile {
      readCustomerProfile: accountInfo {
        id
        firstName
        lastName
        email
        dateOfBirth
        gender
        phone
        status
        subscribedToNewsLetter
        isVerified
        image
      }
    }
  ''';

  /// Get customer addresses (offset-based pagination)
  /// Actual API query: customerAddresses
  /// Returns: AddressPaginator
  static const String getCustomerAddresses = r'''
    query getCustomerAddresses($first: Int!, $page: Int) {
      customerAddresses(first: $first, page: $page) {
        data {
          id
          addressType
          firstName
          lastName
          email
          companyName
          vatId
          address
          city
          state
          country
          postcode
          phone
          defaultAddress
          useForShipping
          createdAt
          updatedAt
          name
        }
        paginatorInfo {
          currentPage
          lastPage
          hasMorePages
          total
        }
      }
    }
  ''';

  /// Get product reviews (cursor-based pagination)
  /// Actual API query: productReviews
  /// Returns: ProductReviewCursorConnection
  /// Note: Pass productId to fetch reviews for a specific product.
  static const String getProductReviews = r'''
    query productReviews($first: Int, $after: String, $productId: Int) {
      productReviews(first: $first, after: $after, product_id: $productId) {
        edges {
          node {
            id
            _id
            name
            title
            rating
            comment
            status
            createdAt
            updatedAt
          }
          cursor
        }
        pageInfo {
          hasNextPage
          endCursor
        }
        totalCount
      }
    }
  ''';

  /// Get customer reviews (offset-based pagination) with product data.
  /// Bagisto API query: reviewsList(first: Int!, page: Int)
  /// Returns review with nested product for UI display.
  static const String getCustomerReviews = r'''
    query getCustomerReviews($first: Int!, $page: Int) {
      customerReviews: reviewsList(first: $first, page: $page) {
        data {
          id
          title
          comment
          rating
          status
          name
          product {
            id
            sku
            type
            name
            images {
              id
              url
            }
          }
          customer {
            id
          }
          createdAt
          updatedAt
        }
        paginatorInfo {
          currentPage
          lastPage
          hasMorePages
          total
        }
      }
    }
  ''';

  // ─── Address Mutations ───

  /// Set address as default using createAddUpdateCustomerAddress mutation.
  /// The Bagisto API uses the same mutation for create/update with addressId + defaultAddress.
  /// Note: This requires the full address data, so we use createAddUpdateCustomerAddress
  /// with addressId and defaultAddress: true.
  static const String setDefaultAddress = r'''
    mutation setDefaultAddress($input: createAddUpdateCustomerAddressInput!) {
      createAddUpdateCustomerAddress(input: $input) {
        addUpdateCustomerAddress {
          id
          addressId
          firstName
          lastName
          email
          phone
          address1
          address2
          country
          state
          city
          postcode
          useForShipping
          defaultAddress
        }
      }
    }
  ''';

  /// Delete customer address
  /// Bagisto API mutation: createDeleteCustomerAddress(input: createDeleteCustomerAddressInput!)
  static const String deleteCustomerAddress = r'''
    mutation deleteCustomerAddress($input: createDeleteCustomerAddressInput!) {
      createDeleteCustomerAddress(input: $input) {
        deleteCustomerAddress {
          id
        }
      }
    }
  ''';

  /// Add/update a customer address
  /// Discovered via schema introspection on api-demo.bagisto.com:
  ///   mutation: createAddUpdateCustomerAddress
  ///   input type: createAddUpdateCustomerAddressInput
  ///   Fields: addressId (Int, optional — omit for create),
  ///           firstName, lastName, email, phone, address1, address2,
  ///           country, state, city, postcode,
  ///           useForShipping (Boolean), defaultAddress (Boolean)
  static const String createAddUpdateCustomerAddress = r'''
    mutation createAddUpdateCustomerAddress($input: createAddUpdateCustomerAddressInput!) {
      createAddUpdateCustomerAddress(input: $input) {
        addUpdateCustomerAddress {
          id
          addressId
          firstName
          lastName
          email
          phone
          address1
          address2
          country
          state
          city
          postcode
          useForShipping
          defaultAddress
        }
      }
    }
  ''';

  // ─── Profile Mutations ───

  /// Update customer profile
  /// Bagisto API mutation: updateCustomerProfile
  /// Input: firstName, lastName, phone, gender, dateOfBirth, subscribedToNewsLetter
  static const String updateCustomerProfile = r'''
    mutation createCustomerProfileUpdate($input: createCustomerProfileUpdateInput!) {
      createCustomerProfileUpdate(input: $input) {
        customerProfileUpdate {
          id
        }
      }
    }
  ''';

  /// Change customer email — requires current password for verification
  /// Bagisto API mutation: updateCustomerProfile with email + currentPassword
  static const String changeCustomerEmail = r'''
    mutation createCustomerProfileUpdate($input: createCustomerProfileUpdateInput!) {
      createCustomerProfileUpdate(input: $input) {
        customerProfileUpdate {
          id
        }
      }
    }
  ''';

  /// Change customer password — requires current + new password
  /// Bagisto API mutation: updateCustomerProfile with password fields
  static const String changeCustomerPassword = r'''
    mutation createCustomerProfileUpdate($input: createCustomerProfileUpdateInput!) {
      createCustomerProfileUpdate(input: $input) {
        customerProfileUpdate {
          id
        }
      }
    }
  ''';

  /// Delete customer account — requires current password for verification
  /// Bagisto API mutation: deleteCustomerAccount
  static const String deleteCustomerAccount = r'''
    mutation createCustomerProfileDelete($input: createCustomerProfileDeleteInput!) {
      createCustomerProfileDelete(input: $input) {
        customerProfileDelete {
          success
          message
        }
      }
    }
  ''';

  /// Get available countries for address form (cursor-paginated).
  /// Bagisto API: countries(first: Int, after: String)
  /// Returns: CountryCursorConnection { edges { node { ... } } }
  /// We request first=260 to get all countries in one call.
  static const String getCountries = r'''
    query countries($first: Int) {
      countries(first: $first) {
        edges {
          node {
            id
            _id
            code
            name
          }
        }
      }
    }
  ''';

  /// Get states/provinces for a specific country (cursor-paginated).
  /// Bagisto API: countryStates(countryId: Int!, first: Int)
  /// Returns: CountryStateCursorConnection { edges { node { ... } } }
  /// We request first=200 to get all states in one call.
  static const String getCountryStates = r'''
    query countryStates($countryId: Int!, $first: Int) {
      countryStates(countryId: $countryId, first: $first) {
        edges {
          node {
            id
            _id
            code
            defaultName
            countryId
            countryCode
          }
        }
      }
    }
  ''';

  // ─── Wishlist Queries & Mutations ───

  // ─── Wishlist Queries & Mutations ───

  /// Get wishlists (offset-paginated).
  /// Bagisto API: wishlists(first: Int!, page: Int)
  /// Returns: WishlistPaginator
  static const String getWishlists = r'''
    query GetAllWishlists($first: Int!, $page: Int) {
      wishlists(first: $first, page: $page) {
        data {
          id
          product {
            id
            name
            price
            specialPrice
            sku
            type
            description
            urlKey
            images {
              id
              url
            }
          }
          createdAt
          updatedAt
        }
        paginatorInfo {
          currentPage
          lastPage
          hasMorePages
          total
        }
      }
    }
  ''';

  /// Delete a wishlist item.
  /// Bagisto API mutation: removeFromWishlist(productId: ID!)
  static const String deleteWishlist = r'''
    mutation DeleteWishlist($productId: ID!) {
      removeFromWishlist(productId: $productId) {
        success
        message
      }
    }
  ''';

  /// Move a wishlist item to cart.
  /// Bagisto API mutation: moveWishlistToCart(input: moveWishlistToCartInput!)
  static const String moveWishlistToCart = r'''
    mutation MoveWishlistToCart($input: moveWishlistToCartInput!) {
      moveWishlistToCart(input: $input) {
        wishlistToCart {
          message
        }
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Compare Items
  // ──────────────────────────────────────────────

  /// Get compare items (offset-paginated).
  /// Bagisto API query: compareProducts(first: Int!, page: Int)
  /// Returns: CompareProductPaginator
  static const String getCompareItems = r'''
    query GetCompareItems($first: Int!, $page: Int) {
      compareItems: compareProducts(first: $first, page: $page) {
        data {
          id
          product {
            id
            name
            description
            price
            specialPrice
            sku
            type
            urlKey
            images {
              id
              url
            }
          }
          customer {
            id
            email
            firstName
            lastName
          }
          createdAt
          updatedAt
        }
        paginatorInfo {
          currentPage
          lastPage
          hasMorePages
          total
        }
      }
    }
  ''';

  /// Delete a single compare item.
  /// Bagisto API mutation: removeFromCompareProduct(productId: ID!)
  static const String deleteCompareItem = r'''
    mutation DeleteCompareItem($productId: ID!) {
      removeFromCompareProduct(productId: $productId) {
        success
        message
      }
    }
  ''';

  /// Delete all compare items.
  /// Bagisto API mutation: removeAllCompareProducts
  static const String deleteAllCompareItems = r'''
    mutation createDeleteAllCompareItems {
      deleteAllCompareItems: removeAllCompareProducts {
        success
        message
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Create Wishlist
  // ──────────────────────────────────────────────

  /// Add product to wishlist.
  /// Bagisto API mutation: addToWishlist(productId: ID!)
  static const String createWishlist = r'''
    mutation CreateWishlist($productId: ID!) {
      createWishlist: addToWishlist(productId: $productId) {
        success
        message
        wishlist {
          id
          productId
          product {
            id
            name
            price
          }
          createdAt
        }
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Create Compare Item
  // ──────────────────────────────────────────────

  /// Add product to compare list.
  /// Bagisto API mutation: addToCompare(productId: ID!)
  static const String createCompareItem = r'''
    mutation CreateCompareItem($productId: ID!) {
      createCompareItem: addToCompare(productId: $productId) {
        success
        message
        compareProduct {
          id
          productId
          createdAt
          updatedAt
          product {
            id
          }
          customer {
            id
          }
        }
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Customer Orders
  // ──────────────────────────────────────────────

  /// Get customer orders (offset-based pagination).
  /// Bagisto API query: orders(first: Int!, page: Int, input: FilterOrderInput)
  /// Returns: OrderPaginator
  static const String getCustomerOrders = r'''
    query getCustomerOrders($first: Int!, $page: Int, $input: FilterOrderInput) {
      customerOrders: orders(first: $first, page: $page, input: $input) {
        data {
          id
          incrementId
          status
          channelName
          customerEmail
          customerFirstName
          customerLastName
          totalItemCount
          totalQtyOrdered
          grandTotal
          baseGrandTotal
          subTotal
          taxAmount
          discountAmount
          shippingAmount
          shippingTitle
          couponCode
          orderCurrencyCode
          baseCurrencyCode
          createdAt
          updatedAt
        }
        paginatorInfo {
          currentPage
          lastPage
          hasMorePages
          total
        }
      }
    }
  ''';

  /// Get a single customer order detail by ID.
  /// Bagisto API query: orderDetail(id: ID!)
  /// The id is the order ID.
  static const String getCustomerOrder = r'''
    query getCustomerOrder($id: ID!) {
      customerOrder: orderDetail(id: $id) {
        id
        incrementId
        status
        channelName
        customerEmail
        customerFirstName
        customerLastName
        shippingMethod
        shippingTitle
        couponCode
        totalItemCount
        totalQtyOrdered
        grandTotal
        baseGrandTotal
        grandTotalInvoiced
        grandTotalRefunded
        subTotal
        baseSubTotal
        taxAmount
        baseTaxAmount
        discountAmount
        baseDiscountAmount
        shippingAmount
        baseShippingAmount
        baseCurrencyCode
        channelCurrencyCode
        orderCurrencyCode
        payment {
          id
          methodTitle
        }
        items {
          id
          sku
          name
          additional
          price
          total
          qtyOrdered
          qtyShipped
          qtyInvoiced
          qtyCanceled
          qtyRefunded
        }
        addresses {
          id
          addressType
          parentAddressId
          customerId
          cartId
          orderId
          name
          firstName
          lastName
          companyName
          address
          city
          state
          country
          postcode
          useForShipping
          email
          phone
          gender
          vatId
          defaultAddress
          createdAt
          updatedAt
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Create Product Review
  // ──────────────────────────────────────────────

  /// Create a product review.
  /// Bagisto API mutation: createProductReview(input: createProductReviewInput!)
  /// Required: productId, title, comment, rating, name
  /// Optional: email, status, attachments, clientMutationId
  static const String createProductReview = r'''
    mutation createProductReview($input: createProductReviewInput!) {
      createProductReview(input: $input) {
        productReview {
          id
          _id
          name
          title
          rating
          comment
          status
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Customer Invoices
  // ──────────────────────────────────────────────

  /// Get customer invoices with items (cursor-based pagination).
  /// Bagisto API query: customerInvoices(first: Int, after: String, orderId: Int, state: String)
  /// Returns: CustomerInvoiceCursorConnection with items
  static const String getCustomerInvoices = r'''
    query getCustomerInvoices($first: Int, $after: String, $orderId: Int, $state: String) {
      customerInvoices(first: $first, after: $after, orderId: $orderId, state: $state) {
        edges {
          cursor
          node {
            _id
            incrementId
            state
            totalQty
            orderCurrencyCode
            grandTotal
            baseGrandTotal
            subTotal
            baseSubTotal
            shippingAmount
            baseShippingAmount
            taxAmount
            baseTaxAmount
            discountAmount
            baseDiscountAmount
            baseCurrencyCode
            orderCurrencyCode
            transactionId
            createdAt
            updatedAt
            items {
              edges {
                node {
                  id
                  _id
                  sku
                  parentId
                  name
                  price
                  qty
                  total
                  basePrice
                  description
                  baseTotal
                  taxAmount
                  baseTaxAmount
                  discountPercent
                  discountAmount
                  baseDiscountAmount
                  priceInclTax
                  basePriceInclTax
                  totalInclTax
                  baseTotalInclTax
                  productId
                  productType
                  orderItemId
                  invoiceId
                  createdAt
                  updatedAt
                }
              }
            }
          }
        }
        pageInfo {
          endCursor
          startCursor
          hasNextPage
          hasPreviousPage
        }
        totalCount
      }
    }
  ''';

  /// Get a single customer invoice detail by ID with items.
  /// Bagisto API query: customerInvoice(id: ID!)
  /// The id is the IRI format (e.g. "/api/shop/customer-invoices/1").
  static const String getCustomerInvoice = r'''
    query getCustomerInvoice($id: ID!) {
      customerInvoice(id: $id) {
        _id
        incrementId
        state
        totalQty
        emailSent
        grandTotal
        baseGrandTotal
        downloadUrl
        subTotal
        baseSubTotal
        shippingAmount
        baseShippingAmount
        taxAmount
        baseTaxAmount
        discountAmount
        baseDiscountAmount
        shippingTaxAmount
        baseShippingTaxAmount
        subTotalInclTax
        baseSubTotalInclTax
        shippingAmountInclTax
        baseShippingAmountInclTax
        baseCurrencyCode
        channelCurrencyCode
        orderCurrencyCode
        transactionId
        reminders
        nextReminderAt
        createdAt
        updatedAt
        items {
          edges {
            node {
              id
              _id
              sku
              name
              qty
              price
              total
              basePrice
              description
              baseTotal
              taxAmount
              baseTaxAmount
              discountPercent
              discountAmount
              baseDiscountAmount
              priceInclTax
              basePriceInclTax
              totalInclTax
              baseTotalInclTax
              productId
              productType
              orderItemId
              invoiceId
              createdAt
              updatedAt
            }
          }
        }
      }
    }
  ''';

  // ──────────────────────────────────────────────
  // Reorder
  // ──────────────────────────────────────────────

  /// Reorder an existing order.
  /// Bagisto API mutation: createReorderOrder(input: reorderOrderInput!)
  /// Required: orderId (Int)
  /// Returns: success, message, orderId, itemsAddedCount
  static const String reorderOrder = r'''
mutation createReorderOrder($input: createReorderOrderInput!) {
  createReorderOrder(input: $input) {
    reorderOrder {
      success
      message
      orderId
      itemsAddedCount
    }
  }
}
''';

  // ──────────────────────────────────────────────
  // Customer Shipments
  // ──────────────────────────────────────────────

  /// Get customer order shipments (cursor-based pagination).
  /// Bagisto API query: customerOrderShipments(orderId: Int!)
  /// Returns: CustomerOrderShipmentCursorConnection with items
  static const String getCustomerOrderShipments = r'''
    query getOrderShipments($orderId: Int!) {
      customerOrderShipments(orderId: $orderId) {
        edges {
          node {
            id
            _id
            status
            trackNumber
            carrierTitle
            totalQty
            createdAt
            items {
              edges {
                node {
                  id
                  name
                  sku
                  qty
                }
              }
            }
            shippingNumber
          }
        }
        totalCount
      }
    }
  ''';

  /// Get a single customer order shipment detail by ID.
  /// Bagisto API query: customerOrderShipment(id: Int!)
  /// Returns: Shipment with items
  static const String getCustomerOrderShipment = r'''
    query getOrderShipment($id: Int!) {
      customerOrderShipment(id: $id) {
        id
        _id
        status
        trackNumber
        carrierTitle
        totalQty
        createdAt
        items {
          edges {
            node {
              id
              name
              sku
              qty
            }
          }
        }
        shippingNumber
      }
    }
  ''';

  /// Get available locales for language selection
  /// Actual API query: locales
  /// Returns: LocalesCursorConnection with available languages/locales
  static const String getLocales = r'''
    query getLocales {
      locales {
        edges {
          node {
            id
            _id
            code
            name
            direction
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  ''';

  /// Get available currencies for currency selection
  static const String getCurrencies = r'''
    query allCurrency {
      currencies {
        edges {
          node {
            id
            _id
            code
            name
            symbol
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  ''';

  /// Get customer downloadable products (cursor-based pagination)
  /// Bagisto API query: customerDownloadableProducts(first: Int, after: String)
  /// Returns: DownloadableProductCursorConnection with product details
  static const String getCustomerDownloadableProducts = r'''
    query getCustomerDownloadableProducts($first: Int, $after: String) {
      customerDownloadableProducts(first: $first, after: $after) {
        edges {
          cursor
          node {
            _id
            productName
            name
            fileName
            downloadUrl
            type
            downloadBought
            downloadUsed
            downloadCanceled
            status
            remainingDownloads
            order {
              _id
              incrementId
              status
            }
            createdAt
            updatedAt
          }
        }
        pageInfo {
          endCursor
          startCursor
          hasNextPage
          hasPreviousPage
        }
        totalCount
      }
    }
  ''';

  /// Get CMS pages list
  /// Bagisto API query: pages
  /// Returns: PagesCursorConnection with page details including translations
  static const String getCmsPages = r'''
    query getCmsPages {
      pages {
        edges {
          node {
            id
            _id
            layout
            createdAt
            updatedAt
            translation {
              id
              _id
              pageTitle
              urlKey
              htmlContent
              metaTitle
              metaDescription
              metaKeywords
              locale
            }
          }
        }
      }
    }
  ''';

  /// Create contact us submission
  /// Bagisto API mutation: createContactUs
  /// Returns: ContactUsResponse with success and message
  static const String createContactUs = r'''
    mutation createContactUs($input: createContactUsInput!) {
      createContactUs(input: $input) {
        contactUs {
          success
          message
        }
      }
    }
  ''';
}
