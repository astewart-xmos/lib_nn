#pragma once

#include "f2d_c_types.h"
#include <type_traits>

namespace nn {
namespace filt2d {


////////////////////////////////////////////////////////
/////
////////////////////////////////////////////////////////

template <typename T>
static inline T* advancePointer(T* orig, int32_t offset_bytes)
{
  return (T*) (((int32_t)orig)+offset_bytes);
}



////////////////////////////////////////////////////////
/////
////////////////////////////////////////////////////////

class ImageVect {

  public:

    const int row;
    const int col;
    const int channel;

    ImageVect(
      int const img_row,
      int const img_col,
      int const img_chan)
        : row(img_row), col(img_col), channel(img_chan){}

    ImageVect operator+(ImageVect const& other) const
      { return this->add(other.row, other.col, other.channel);  }

    ImageVect operator-(ImageVect const& other) const
      { return this->sub(other.row, other.col, other.channel);  }

    ImageVect add(int const rows, int const cols, int const chans) const
      { return ImageVect(this->row + rows, this->col + cols, this->channel + chans); }

    ImageVect sub(int const rows, int const cols, int const chans) const
      { return ImageVect(this->row - rows, this->col - cols, this->channel - chans); }
};


class ImageRegion {

  public:

    struct {
      const int row;
      const int col;
      const int channel;
    } start;

    struct {
      const unsigned height;
      const unsigned width;
      const unsigned depth;
    } shape;

  public:

    ImageRegion(
      int const row,
      int const col,
      int const chan,
      unsigned const height,
      unsigned const width,
      unsigned const depth)
        : start{row,col,chan}, shape{height,width,depth} {}

};


class PointerCovector {
  public:

    int16_t row_bytes;
    int16_t col_bytes;
    int16_t chan_bytes;
    int16_t const zero = 0;

  public:

    PointerCovector(
      int16_t rowbytes, 
      int16_t colbytes, 
      int16_t chanbytes)
        : row_bytes(rowbytes), col_bytes(colbytes), chan_bytes(chanbytes) {}

    int32_t dot(ImageVect coords) const;

    int32_t dot(int row, int col, int channel) const;
    
    template <typename T>
    T* resolve(T* base_address, ImageVect coords) const
      { return this->resolve<T>(base_address, coords.row, coords.col, coords.channel); }

    template <typename T>
    T* resolve(T* base_address, int row, int col, int channel) const
      { return (T*)(((int32_t)base_address) + this->dot(row, col, channel)); }
};



class PaddingTransform {

  public: 

    struct {
      int16_t const top;
      int16_t const left;
      int16_t const bottom;
      int16_t const right;
    } initial;
    struct {
      int16_t const top;
      int16_t const left;
      int16_t const bottom;
      int16_t const right;
    } stride;

  public:
    PaddingTransform(
      int16_t init_top, int16_t init_left, int16_t init_bottom, int16_t init_right,
      int16_t stri_top, int16_t stri_left, int16_t stri_bottom, int16_t stri_right) 
        : initial {init_top, init_left, init_bottom, init_right},
          stride {stri_top, stri_left, stri_bottom, stri_right} {}
};




////////////////////////////////////////////////////////
/////
////////////////////////////////////////////////////////

class ICoordinateConverter {

  protected:

    InputCoordTransform const& getTransform() const;

    ImageVect getInputCoords(ImageVect const& output_coords) const {
      auto const& transform = this->getTransform();
      return ImageVect(
        transform.start.row     + output_coords.row     * transform.stride.rows,
        transform.start.col     + output_coords.col     * transform.stride.cols,
        transform.start.channel + output_coords.channel * transform.stride.channels );

    }

};


class IPaddingResolver {

  
  protected:

    virtual PaddingTransform const& getPaddingTransform() const = 0;


    padding_t const getPadding(
      ImageVect const& output_coords,
      bool const get_unsigned) const;
};


}}